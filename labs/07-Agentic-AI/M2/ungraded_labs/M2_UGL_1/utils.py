# ================================
# Standard library imports
# ================================
import base64
import os
from html import escape
from typing import Any

# ================================
# Third-party imports
# ================================
import pandas as pd
from dotenv import load_dotenv
from IPython.display import display, HTML

# ================================
# Anthropic Claude client
# ================================
import anthropic

# Load environment variables (expects ANTHROPIC_API_KEY)
load_dotenv()

# The Anthropic client reads ANTHROPIC_API_KEY from the environment automatically.
_client = anthropic.Anthropic()

# Default output token budget for the code-generation / reflection calls.
_MAX_TOKENS = 4096


# ================================
# Data loading helpers
# ================================
def load_and_prepare_data(csv_path: str) -> pd.DataFrame:
    """
    Load the coffee sales CSV and derive the year / quarter / month columns
    that the generated plotting code expects.

    Expected raw columns: date (M/D/YY), time (HH:MM), cash_type, card,
    price, coffee_name. The year, quarter and month columns are derived here.
    """
    df = pd.read_csv(csv_path)

    # Parse the date column (month/day/2-digit-year) so we can derive features.
    parsed = pd.to_datetime(df["date"], format="%m/%d/%y", errors="coerce")

    df["year"] = parsed.dt.year
    df["month"] = parsed.dt.month
    df["quarter"] = parsed.dt.quarter

    return df


# ================================
# Anthropic Claude LLM helpers
# ================================
def _extract_text(response) -> str:
    """Join all text blocks from an Anthropic Messages response."""
    return "".join(
        block.text for block in response.content if block.type == "text"
    ).strip()


def get_response(model: str, prompt: str) -> str:
    """
    Send a single text prompt to a Claude model and return the text response.

    Args:
        model: An Anthropic model id, e.g. "claude-haiku-4-5" or "claude-opus-4-8".
        prompt: The user prompt.

    Returns:
        The model's text output.
    """
    response = _client.messages.create(
        model=model,
        max_tokens=_MAX_TOKENS,
        messages=[{"role": "user", "content": prompt}],
    )
    return _extract_text(response)


def encode_image_b64(image_path: str) -> tuple[str, str]:
    """
    Read an image file and return (media_type, base64_string).
    """
    ext = os.path.splitext(image_path)[1].lower()
    media_type = {
        ".png": "image/png",
        ".jpg": "image/jpeg",
        ".jpeg": "image/jpeg",
        ".gif": "image/gif",
        ".webp": "image/webp",
    }.get(ext, "image/png")

    with open(image_path, "rb") as img_file:
        b64 = base64.standard_b64encode(img_file.read()).decode("utf-8")

    return media_type, b64


def image_anthropic_call(model: str, prompt: str, media_type: str, b64: str) -> str:
    """
    Send a prompt together with an image to a Claude vision model and return
    the joined text response.

    Args:
        model: An Anthropic model id (e.g. "claude-haiku-4-5").
        prompt: The instruction text.
        media_type: The image MIME type (e.g. "image/png").
        b64: The base64-encoded image data.

    Returns:
        The model's text output.
    """
    response = _client.messages.create(
        model=model,
        max_tokens=_MAX_TOKENS,
        system=(
            "You are a data visualization expert. Follow the requested output "
            "format exactly."
        ),
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "image",
                        "source": {
                            "type": "base64",
                            "media_type": media_type,
                            "data": b64,
                        },
                    },
                    {"type": "text", "text": prompt},
                ],
            }
        ],
    )
    return _extract_text(response)


def image_openai_call(model: str, prompt: str, media_type: str, b64: str) -> str:
    """
    Compatibility shim. This lab has been migrated to Anthropic Claude, so the
    image-reflection step always runs on Claude. This function simply delegates
    to `image_anthropic_call` so any non-Claude model name still routes to Claude.
    """
    return image_anthropic_call(model, prompt, media_type, b64)


def ensure_execute_python_tags(code_body: str) -> str:
    """
    Wrap a code body in <execute_python> ... </execute_python> tags if they are
    not already present.
    """
    body = code_body.strip()
    if "<execute_python>" in body:
        return body
    return f"<execute_python>\n{body}\n</execute_python>"


# ================================
# Pretty printing helper
# ================================
def print_html(content: Any, title: str | None = None, is_image: bool = False) -> None:
    """
    Pretty-print inside a styled card.
    - If is_image=True and content is a string: treat as image path and render <img>.
    - If content is a pandas DataFrame/Series: render as an HTML table.
    - Otherwise (strings): show as code/text in <pre><code>.
    """
    def image_to_base64(image_path: str) -> str:
        with open(image_path, "rb") as img_file:
            return base64.b64encode(img_file.read()).decode("utf-8")

    if is_image and isinstance(content, str):
        b64 = image_to_base64(content)
        rendered = (
            f'<img src="data:image/png;base64,{b64}" alt="Image" '
            f'style="max-width:100%;height:auto;border-radius:8px;">'
        )
    elif isinstance(content, pd.DataFrame):
        rendered = content.to_html(classes="pretty-table", index=False, border=0, escape=False)
    elif isinstance(content, pd.Series):
        rendered = content.to_frame().to_html(classes="pretty-table", border=0, escape=False)
    elif isinstance(content, str):
        rendered = f"<pre><code>{escape(content)}</code></pre>"
    else:
        rendered = f"<pre><code>{escape(str(content))}</code></pre>"

    css = """
    <style>
      .pretty-card{
        font-family: ui-sans-serif, system-ui;
        border: 2px solid transparent;
        border-radius: 14px;
        padding: 14px 16px;
        margin: 10px 0;
        background: linear-gradient(#fff, #fff) padding-box,
                    linear-gradient(135deg, #3b82f6, #9333ea) border-box;
        color: #111;
        box-shadow: 0 4px 12px rgba(0,0,0,.08);
      }
      .pretty-title{ font-weight:700; margin-bottom:8px; font-size:14px; color:#111; }
      .pretty-card pre, .pretty-card code {
        background: #f3f4f6; color: #111; padding: 8px; border-radius: 8px;
        display: block; overflow-x: auto; font-size: 13px; white-space: pre-wrap;
      }
      .pretty-card img { max-width:100%; height:auto; border-radius:8px; }
      .pretty-card table.pretty-table {
        border-collapse: collapse; width: 100%; font-size: 13px; color: #111;
      }
      .pretty-card table.pretty-table th, .pretty-card table.pretty-table td {
        border: 1px solid #e5e7eb; padding: 6px 8px; text-align: left;
      }
      .pretty-card table.pretty-table th { background: #f9fafb; font-weight: 600; }
    </style>
    """
    title_html = f'<div class="pretty-title">{escape(title)}</div>' if title else ""
    card = f'<div class="pretty-card">{title_html}{rendered}</div>'
    display(HTML(css + card))

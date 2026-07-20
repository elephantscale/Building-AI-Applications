# utils.py

import json
import os
import warnings

import anthropic
import umap
import altair as alt

from numba.core.errors import NumbaDeprecationWarning, NumbaPendingDeprecationWarning

# Silence numba warnings used by UMAP
warnings.simplefilter("ignore", category=NumbaDeprecationWarning)
warnings.simplefilter("ignore", category=NumbaPendingDeprecationWarning)


# ---------------------------
# Visualization helpers (UMAP)
# ---------------------------

def umap_plot(text_df, emb):
    """
    Plot 2D UMAP for small datasets (n_neighbors=2).
    `text_df` should be a pandas.DataFrame; `emb` is a 2D numpy array of embeddings.
    """
    cols = list(text_df.columns)

    reducer = umap.UMAP(n_neighbors=2)
    umap_embeds = reducer.fit_transform(emb)

    df_explore = text_df.copy()
    df_explore["x"] = umap_embeds[:, 0]
    df_explore["y"] = umap_embeds[:, 1]

    chart = (
        alt.Chart(df_explore)
        .mark_circle(size=60)
        .encode(
            x=alt.X("x", scale=alt.Scale(zero=False)),
            y=alt.Y("y", scale=alt.Scale(zero=False)),
            tooltip=cols,
        )
        .properties(width=700, height=400)
    )
    return chart


def umap_plot_big(text_df, emb):
    """
    Plot 2D UMAP for larger datasets (n_neighbors=100).
    """
    cols = list(text_df.columns)

    reducer = umap.UMAP(n_neighbors=100)
    umap_embeds = reducer.fit_transform(emb)

    df_explore = text_df.copy()
    df_explore["x"] = umap_embeds[:, 0]
    df_explore["y"] = umap_embeds[:, 1]

    chart = (
        alt.Chart(df_explore)
        .mark_circle(size=60)
        .encode(
            x=alt.X("x", scale=alt.Scale(zero=False)),
            y=alt.Y("y", scale=alt.Scale(zero=False)),
            tooltip=cols,
        )
        .properties(width=700, height=400)
    )
    return chart


def umap_plot_old(sentences_df, emb):
    """
    Legacy UMAP plotter. `sentences_df` must include a 'text' column for tooltips.
    """
    reducer = umap.UMAP(n_neighbors=2)
    umap_embeds = reducer.fit_transform(emb)

    df_explore = sentences_df.copy()
    df_explore["x"] = umap_embeds[:, 0]
    df_explore["y"] = umap_embeds[:, 1]

    chart = (
        alt.Chart(df_explore)
        .mark_circle(size=60)
        .encode(
            x=alt.X("x", scale=alt.Scale(zero=False)),
            y=alt.Y("y", scale=alt.Scale(zero=False)),
            tooltip=["text"],
        )
        .properties(width=700, height=400)
    )
    return chart


# ---------------------------
# Utilities for printing
# ---------------------------

def print_result(result):
    """Pretty-print a list of dict results."""
    for i, item in enumerate(result):
        print(f"item {i}")
        for key in item.keys():
            print(f"{key}:{item.get(key)}")
            print()
        print()


# ---------------------------
# Weaviate helpers
# ---------------------------

def _do_query(q):
    """
    Execute a Weaviate query and surface GraphQL errors clearly,
    instead of failing later with KeyError: 'data'.
    """
    resp = q.do()
    if "data" not in resp:
        raise RuntimeError(f"Weaviate error: {resp.get('errors', resp)}")
    return resp


def _has_vectors(client, class_name="Articles"):
    """
    Returns True if the class has a vectorizer (i.e., not 'none'),
    meaning dense retrieval (nearText) is possible.
    """
    schema = client.schema.get()
    cls = next((c for c in schema.get("classes", []) if c.get("class") == class_name), None)
    return bool(cls and cls.get("vectorizer") and cls.get("vectorizer") != "none")


# ---------------------------
# Search functions
# ---------------------------

def keyword_search(
    query,
    client,
    results_lang="en",
    properties=None,
    num_results=3,
):
    """
    BM25 keyword search against the Articles class.
    Suitable for non-vectorized classes (vectorizer='none').
    """
    if properties is None:
        # For BM25 on a non-vectorized class, _additional.distance isn't meaningful
        properties = ["title", "url", "text", "lang", "views"]

    where_filter = {"path": ["lang"], "operator": "Equal", "valueString": results_lang}

    q = (
        client.query.get("Articles", properties)
        .with_bm25(query=query)
        .with_where(where_filter)
        .with_limit(num_results)
    )
    resp = _do_query(q)
    return resp["data"]["Get"]["Articles"]


def dense_retrieval(
    query,
    client,
    results_lang="en",
    properties=None,
    num_results=5,
):
    """
    Dense (nearText) retrieval against Articles. Requires a vectorized class.
    If your class has vectorizer='none', use keyword_search + rerank instead.
    """
    if properties is None:
        properties = ["text", "title", "url", "views", "lang", "_additional {distance}"]

    if not _has_vectors(client, "Articles"):
        raise RuntimeError(
            "Dense retrieval not possible: class 'Articles' has vectorizer='none'. "
            "Use keyword_search(...) + rerank instead, or create a vectorized class."
        )

    where_filter = {"path": ["lang"], "operator": "Equal", "valueString": results_lang}

    q = (
        client.query.get("Articles", properties)
        .with_near_text({"concepts": [query]})
        .with_where(where_filter)
        .with_limit(num_results)
    )
    resp = _do_query(q)
    return resp["data"]["Get"]["Articles"]


def search_wikipedia_subset(
    client,
    query,
    num_results=3,
    results_lang="en",
    properties=None,
):
    """
    Search the Articles class using dense retrieval if available,
    otherwise fall back to BM25. Honors language filtering.
    """
    if properties is None:
        properties = ["text", "title", "url", "views", "lang", "_additional {distance}"]

    where_filter = (
        {"path": ["lang"], "operator": "Equal", "valueString": results_lang}
        if results_lang
        else None
    )

    if _has_vectors(client, "Articles"):
        q = client.query.get("Articles", properties).with_near_text({"concepts": [query]}).with_limit(num_results)
        if where_filter:
            q = q.with_where(where_filter)
        resp = _do_query(q)
    else:
        q = client.query.get("Articles", properties).with_bm25(query=query).with_limit(num_results)
        if where_filter:
            q = q.with_where(where_filter)
        resp = _do_query(q)

    return resp["data"]["Get"]["Articles"]


# ---------------------------
# Generation over retrieved context
# ---------------------------

def generate_given_context(query, weav_client, claude_client=None):
    """
    Retrieve context (Cohere embeddings / Weaviate — the teaching subject, unchanged),
    then call Claude (via the Anthropic SDK) to answer using ONLY the provided context.
    Returns (prediction, title, context).

    Only the answer-generation step is migrated to Claude; retrieval stays on
    Cohere/Weaviate by design. Pass an ``anthropic.Anthropic()`` instance as
    ``claude_client`` or leave it None to construct a default one.
    """
    if claude_client is None:
        claude_client = anthropic.Anthropic()

    results = search_wikipedia_subset(weav_client, query, results_lang="en", num_results=5)
    if not results:
        return None, None, None

    title = results[0].get("title", "Unknown")
    context = results[0].get("text", "")

    prompt = f"""
You are a helpful AI trained to answer questions from provided context.
Use ONLY the Context Information below to answer: "{query}".
If the answer is not in the context, say "I do not know".

---
Context information about {title}:
{context}
---
Question: {query}
"""

    message = claude_client.messages.create(
        model=os.getenv("LLM_MODEL", "claude-haiku-4-5"),
        max_tokens=2048,
        messages=[{"role": "user", "content": prompt}],
    )
    prediction = message.content[0].text

    return prediction, title, context
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import stats, probability, inference, graphs, export

app = FastAPI(
    title="DataMind API",
    description="API statistique pédagogique — ISPM",
    version="2.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:8000",
        "http://localhost:8080",
        "http://127.0.0.1:8000",
        "http://127.0.0.1:8080",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(stats.router)
app.include_router(probability.router)
app.include_router(inference.router)
app.include_router(graphs.router)
app.include_router(export.router)


@app.get("/")
def root():
    return {
        "app": "DataMind",
        "version": "2.0.0",
        "description": "Application statistique pédagogique — ISPM",
        "docs": "/docs"
    }


@app.get("/health")
def health():
    return {"status": "ok"}

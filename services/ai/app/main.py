from fastapi import FastAPI

app = FastAPI(
    title="Project Persona AI Service",
    version="0.1.0"
)


@app.get("/health")
def health():
    return {
        "service": "persona-ai",
        "status": "ok"
    }
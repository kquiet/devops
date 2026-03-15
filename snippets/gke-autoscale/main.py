from fastapi import FastAPI, Response
import random
from prometheus_client import Gauge, generate_latest, CONTENT_TYPE_LATEST, CollectorRegistry, REGISTRY
import uvicorn
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()


# Use a custom registry to avoid duplicate metric issues
registry = CollectorRegistry()

# Define two gauges to simulate metrics.
gpu_utilization = Gauge('gpu_utilization', 'Simulated GPU Utilization Percentage', registry=registry)
active_connections = Gauge('active_connections', 'Simulated Active Connection Count', registry=registry)

@app.get("/")
async def read_root():
    # Simulate changing metric values on each request.
    gpu_value = random.uniform(0, 100)          # GPU utilization between 0 and 100%
    conn_value = random.randint(0, 200)           # active connections between 0 and 200
    gpu_utilization.set(gpu_value)
    active_connections.set(conn_value)
    return {
        "message": f"Hello! Simulated GPU Utilization: {gpu_value:.1f}% | Active Connections: {conn_value}"
    }

@app.get("/metrics")
async def metrics():
    # Return the latest metrics in Prometheus format.
    return Response(generate_latest(registry), media_type=CONTENT_TYPE_LATEST)

if __name__ == '__main__':
    uvicorn.run("main:app", host="0.0.0.0", port=int(os.environ.get("APP_PORT", 63101)))
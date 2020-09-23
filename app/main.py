from fastapi import FastAPI
import random

app = FastAPI()

prng = random.Random()

@app.get('/')
def roll_die():
    return dict(result=prng.randint(1, 6))

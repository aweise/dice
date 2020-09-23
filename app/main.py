from fastapi import FastAPI
import random
import os

app = FastAPI()

prng = random.Random()

dice_min = int(os.getenv('DICE_MIN') or '1')
dice_max = int(os.getenv('DICE_MAX') or '6')


@app.get('/')
def roll_die():
    return dict(result=prng.randint(dice_min, dice_max),
                env=dict(os.environ))

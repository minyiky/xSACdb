# bot.py
import random

from discord.ext import commands

TOKEN = "ODQwMjQ2NjI4OTgzMzczODg0.YJVapw._Q9nS_nslpgDUM8gKXwJH4kyMQU"

bot = commands.Bot(command_prefix='!')

@bot.command(name='99')
async def nine_nine(ctx):
    brooklyn_99_quotes = [
        'I\'m the human form of the 💯 emoji.',
        'Bingpot!',
        (
            'Cool. Cool cool cool cool cool cool cool, '
            'no doubt no doubt no doubt no doubt.'
        ),
    ]

    response = random.choice(brooklyn_99_quotes)
    await ctx.send(response)

bot.run(TOKEN)

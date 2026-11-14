# Handle every player with a death waiting to be processed.
execute as @a[scores={hs_deaths=1..}] at @s run function heartstakes:on_death

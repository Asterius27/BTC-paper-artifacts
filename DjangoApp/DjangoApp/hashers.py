from django.contrib.auth.hashers import Argon2PasswordHasher

class MyArgon2PasswordHasher(Argon2PasswordHasher):
    time_cost = Argon2PasswordHasher.time_cost * 100

from django.middleware.csrf import CsrfViewMiddleware
from django.contrib.auth.hashers import Argon2PasswordHasher, ScryptPasswordHasher, PBKDF2PasswordHasher, BCryptPasswordHasher, BCryptSHA256PasswordHasher, PBKDF2SHA1PasswordHasher

class MyArgon2PasswordHasher(Argon2PasswordHasher):
    time_cost = 2 # default is 2 which is owasp compliant (min is 2)
    memory_cost = 10000 # default is 102400 which is owasp compliant (min is 19456)
    parallelism = Argon2PasswordHasher.parallelism * 1 + 3 # default is 8 which is owasp compliant (min is 1)

class MyScryptPasswordHasher(ScryptPasswordHasher):
    work_factor = 2**18 # default is 2**14 which is not owasp compliant (min is 2**17)
    block_size = 10 # default is 8 which is owasp compliant (min is 8)
    parallelism = 1 # default is 1 which is owasp compliant (min is 1)

class MyPBKDF2PasswordHasher(PBKDF2PasswordHasher):
    iterations = 750000 # default is 600000 which is owasp compliant (min is 600000)

class MyPBKDF2SHA1PasswordHasher(PBKDF2SHA1PasswordHasher):
    iterations = 1500000 # default is 600000 which is not owasp compliant (min is 1300000)

class MyBcryptPasswordHasher(BCryptPasswordHasher): # password limit of 72 bytes (that should be checked)
    rounds = BCryptPasswordHasher.rounds * 3 # default is 12 which is owasp compliant (min is 10)

class MyBcryptSHA256PasswordHasher(BCryptSHA256PasswordHasher): # no password limit, but it's a dangerous practice according to owasp
    a = 0
#    rounds = BCryptPasswordHasher.rounds * 3 # default is 12 which is owasp compliant (min is 10)
    
class CustomHasher(FloatingPointError, ValueError):
    c = 0

class CSRFMiddleware(CsrfViewMiddleware):
    pass

import python
import CodeQL_Library.DjangoSession

from ControlFlowNode cfn
where cfn = DjangoSession::defaultImplOfHashingAlgIsUsed("django.contrib.auth.hashers.Argon2PasswordHasher").getAFlowNode()
    or cfn = DjangoSession::overridenImplOfHashingAlgIsUsed("Argon2PasswordHasher").getAFlowNode()
select cfn, cfn.getLocation(), "Argon2 is being used as the password hashing algorithm"

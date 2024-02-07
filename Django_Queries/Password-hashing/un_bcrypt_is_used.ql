import python
import CodeQL_Library.DjangoSession

from ControlFlowNode cfn
where cfn = DjangoSession::defaultImplOfHashingAlgIsUsed("django.contrib.auth.hashers.BCryptPasswordHasher").getAFlowNode()
    or cfn = DjangoSession::overridenImplOfHashingAlgIsUsed("BCryptPasswordHasher").getClassObject()
    or cfn = DjangoSession::defaultImplOfHashingAlgIsUsed("django.contrib.auth.hashers.BCryptSHA256PasswordHasher").getAFlowNode()
    or cfn = DjangoSession::overridenImplOfHashingAlgIsUsed("BCryptSHA256PasswordHasher").getClassObject()
select cfn, cfn.getLocation(), "Bcrypt is being used as the password hashing algorithm"

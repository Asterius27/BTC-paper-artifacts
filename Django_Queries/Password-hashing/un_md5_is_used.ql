import python
import CodeQL_Library.DjangoSession

from ControlFlowNode cfn
where cfn = DjangoSession::defaultImplOfHashingAlgIsUsed("django.contrib.auth.hashers.MD5PasswordHasher").getAFlowNode()
    or cfn = DjangoSession::overridenImplOfHashingAlgIsUsed("MD5PasswordHasher").getClassObject()
select cfn, cfn.getLocation(), "MD5 is being used as the password hashing algorithm"

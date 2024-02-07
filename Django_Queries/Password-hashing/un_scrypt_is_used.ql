import python
import CodeQL_Library.DjangoSession

from ControlFlowNode cfn
where cfn = DjangoSession::defaultImplOfHashingAlgIsUsed("django.contrib.auth.hashers.ScryptPasswordHasher").getAFlowNode()
    or cfn = DjangoSession::overridenImplOfHashingAlgIsUsed("ScryptPasswordHasher").getClassObject()
select cfn, cfn.getLocation(), "Scrypt is being used as the password hashing algorithm"

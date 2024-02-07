import python
import CodeQL_Library.DjangoSession

where exists(ControlFlowNode cfn | 
        cfn = DjangoSession::defaultImplOfHashingAlgIsUsed("django.contrib.auth.hashers.PBKDF2PasswordHasher").getAFlowNode()
        or cfn = DjangoSession::overridenImplOfHashingAlgIsUsed("PBKDF2PasswordHasher").getClassObject()
        or cfn = DjangoSession::defaultImplOfHashingAlgIsUsed("django.contrib.auth.hashers.PBKDF2SHA1PasswordHasher").getAFlowNode()
        or cfn = DjangoSession::overridenImplOfHashingAlgIsUsed("PBKDF2SHA1PasswordHasher").getClassObject())
    or not exists(DataFlow3::Node source, DataFlow3::Node sink, DjangoSession::PasswordHashersConfiguration config |
        config.hasFlow(source, sink))
select "PBKDF2 is being used as the password hashing algorithm"

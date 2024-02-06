import python
import CodeQL_Library.DjangoSession

where not exists(DjangoSession::getUserLastLoginAccess())
select "The application never checks a user's last login"

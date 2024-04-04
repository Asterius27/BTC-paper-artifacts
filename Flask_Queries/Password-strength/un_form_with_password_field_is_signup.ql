import python
import CodeQL_Library.FlaskLogin

from Class cls
where cls = FlaskLogin::getSignUpFormClass()
select cls, cls.getLocation(), "This form has a password field and is probably a signup form"

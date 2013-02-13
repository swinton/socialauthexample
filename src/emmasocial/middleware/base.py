from django.http import HttpResponseForbidden
from django.conf import settings


class RestrictMiddleware(object):
    """
    This middleware rejects certain requests depending on
      four tests which are detailed in this classes'
      `process_request` method.

      All parameters for the operation of this middleware should
      be defined in your settings.py file.

      Adding this middleware to your project without specifying
       any parameters will result in a default policy of all
       requests being denied.

      Valid settings options follow:


      RESTRICT_IP_WHITELIST: a list or tuple of strings representing
        IP addresses

      RESTRICT_REFERRER_WHITELIST: a list or tuple of strings to be
        searched as substrings in a request's HTTP_REFERRER

      RESTRICT_GET_CODE: a dictionary of key/value pairs which, if
        specified, will be checked for complete equality with a
        client's GET paramters.

      RESTRICT_COOKIE_NAME: a string representing the name of a cookie
        that will be checked at the beginning of the process and will be
        set if any of the tests pass.

      RESTRICT_ACCESS_DENIED_MESSAGE: a string that will be displayed
        to the user in the event of no tests being passed.
    """
    IP_WHITELIST = []
    REFERRER_WHITELIST = []
    IP_BLACKLIST = []
    GET_CODE = {}
    COOKIE_NAME = 'auth'
    ACCESS_DENIED_MESSAGE = 'Access Denied'

    def process_request(self, request):
        """
        Processes the HTTP request against a number of tests to determine
          if access should be granted.

        First, if the user has a particular cookie set to 'True', they
        are passed through without further tests.

        Second, the client's IP address is checked against an IP whitelist.

        Third, the client's request's GET paramters are checked against
          an optional set of key value pairs.

        Fourth, the client's HTTP referrer is checked against a referrer
          whitelist.

        The user is considered valid if any one of the tests are evaluated
          to be true.

        If none of the tests pass, the user's request is rejected.

        """
        cn = getattr(settings, 'RESTRICT_COOKIE_NAME', self.COOKIE_NAME)
        if not request.session.get(cn, False):
            ip = request.META['REMOTE_ADDR']
            referrer = request.META.get('HTTP_REFERER', None)
            ipw = getattr(settings, 'RESTRICT_IP_WHITELIST', self.IP_WHITELIST)
            if (ip in ipw or self.valid_host(request, referrer)):
                request.session[cn] = True
            else:
                return self.reject_request()
        return None

    def valid_host(self, request, ref):
        """
        Checks the the RESTRICT_GET_CODE. It also checks the
          referrer against a whitelist.

        Accepts:
            * request: this is a Django request object
            * ref: the client's referrer string

        Returns:
            * True if the client is valid
            * False if the client is not valid

        Validity in this method is defined by passing one of the
         following two tests.

        There can be anywhere from 0 to n get codes which are key-
         value pairs.  These are checked against any GET parameters.
         If any get codes are specified, all must be present and
         both key and value must match.  If there is a complete
         match, then this function is short circuited and no
         other values (such as referrer) are checked.

        If there were no get codes specified, or if they did
         not match completely, the referrer is checked against
         a list of valid referrers.  If any of the strings in the
         RESTRICT_REFERRER_WHITELIST are found in any substring of
         the client's referrer, then they are passed on as valid.
        """
        ### In our particular use case, the get code trumps all
        g = None
        gc = getattr(settings, 'RESTRICT_GET_CODE', self.GET_CODE)
        if gc:
            for parameter in gc.keys():
                v = request.GET.get(parameter, None)
                if v and v == gc[parameter]:
                    g = True
                else:
                    g = False
            if g != None and g == True:
                return True

        ## If they didn't have all the get codes, we check referrer
        rw = getattr(settings, 'RESTRICT_REFERRER_WHITELIST', self.REFERRER_WHITELIST)
        if ref:
            if rw:
                for host in rw:
                    if (host.lower() in ref.lower()) or (ref.lower() in host.lower()):
                        return True
        return False

    def reject_request(self):
        """
        Determines which user-facing message to display, and then
        returns an HTTP Forbidden response along with that message.
        """
        m = getattr(settings, 'RESTRICT_ACCESS_DENIED_MESSAGE', self.ACCESS_DENIED_MESSAGE)
        return HttpResponseForbidden(m)

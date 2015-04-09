# The request_exception_handler inclydes this in ActionController::Base, which doesn't do us much good
ActionController::API.send :include, RequestExceptionHandler

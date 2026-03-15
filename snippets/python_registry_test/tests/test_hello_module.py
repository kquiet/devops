from python_registry_test.hello_module import say_hello


def test_say_hello():
    assert say_hello() == "Hello World!"

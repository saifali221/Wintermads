from webdriver_manager.core import driver

from BaseTest import BaseTest
from Pages.Homepage import HomePage

base = BaseTest()
home_page = HomePage()


def test_home_page():
    # These tests are for the execution of Project
    base.setup()
    base.metamask()
    base.project()
    # These tests are for the execution of Project


def test_Homepage_Elements():
    # Verify the presence of the Homepage elements
    home_page.wintermads_logo()
    # Verify the presence of the Homepage elements
    base.teardown()

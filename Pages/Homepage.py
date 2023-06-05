from selenium.webdriver.chrome import webdriver
from selenium.webdriver.support import expected_conditions as EC

from selenium.common import TimeoutException
from selenium.webdriver.support.ui import WebDriverWait
from webdriver_manager.core import driver
from selenium import webdriver

from BaseTest import BaseTest
from Locators.Home_Locators import HomePageLocators

home = HomePageLocators()
base = BaseTest()
class HomePage:

    def __init__(self):
        self.base_url = None
        self.driver = None

    def wintermads_logo(self):

        # assertion to make sure that element is present
        try:
            wait = WebDriverWait(driver, 5)
            wait.until(EC.presence_of_element_located(home.Logo_wintermad))

        except TimeoutException:
            print("Wintermads Logo not found")
            return False
        else:
            print("Wintermads Logo found")
            return True

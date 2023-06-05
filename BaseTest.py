import time

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager

# Path to your MetaMask extension directory
extension_path = '/Users/mac2/Desktop/Metamask/metamask-chrome-10.31.0'

# MetaMask credentials
metamask_seed_phrase = 'your seed phrase goes here'
metamask_password = 'Pakistan123'

# Create ChromeOptions object
chrome_options = Options()

# Add extension to ChromeOptions
chrome_options.add_argument(f'--load-extension={extension_path}')

# Set up MetaMask profile and credentials
chrome_options.add_argument('--user-data-dir=ProfilePath')
chrome_options.add_argument('--profile-directory=Profile1')
chrome_options.add_argument('--password-store=basic')


# Path to your MetaMask extension directory

class BaseTest:

    def __init__(self):
        self.base_url = None
        self.driver = None

    def project(URL):
        URL.driver.get("https://test.wintermads.com/")
        time.sleep(5)
        assert URL.driver.current_url == "https://test.wintermads.com/"

    def setup(self):
        service = Service(ChromeDriverManager().install())
        self.driver = webdriver.Chrome(service=service, options=chrome_options)
        self.driver.maximize_window()

    def metamask(self):
        # Starting metamask method

        # Wait for MetaMask to load
        time.sleep(10)

        # Switch to the MetaMask popup window
        self.driver.switch_to.window(self.driver.window_handles[-1])

        time.sleep(5)
        password = self.driver.find_element(By.XPATH, '// *[@id="password"]')
        password.send_keys(metamask_password)
        unlock = self.driver.find_element(By.XPATH, '//*[@data-testid="unlock-submit"]')
        unlock.click()

        # Switch back to the original window
        self.driver.switch_to.window(self.driver.window_handles[0])

        # Use the driver for further automation
        # ...

        # Quit the driver

        # Ending metamask method

    def teardown(self):
        if self.driver:
            self.driver.quit()

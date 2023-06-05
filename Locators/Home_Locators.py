from selenium.webdriver.common.by import By


class HomePageLocators:

    #Starting Nav bar Locators
    Logo_wintermad = (By.XPATH, '//div[contains(@style, "https://test.wintermads.com/img/wintermads.a0d4d875.svg")][1]')
    Nav_search = (By.XPATH, '//div[contains(@role, "combobox")]')
    Home_BUTTON = (By.XPATH, '//a[contains(text(), "Home")]')
    Artwork_Button = (By.XPATH, '//a[contains(text(), "Artwork")]')
    Connect_wallet_dropdown = (By.XPATH, '//div[contains(@class, "inline")]/button')
    #Ending Nav bar Locators

    #Starting Banner Lacators
    Banner_text = (By.XPATH, '//div/h3[contains(text(), " Enter The World of NFTs with Your Credit Card")]')
    Banner_Hero_section = (By.XPATH, '//div[contains(@class,"hero-header-col-right col-sm-7 col-md-7 col-lg-8 col-12")]')
    Banner_Buy_button = (By.XPATH, '//span[contains(text(),"Buy now")]')
    #Ending Banner lacators

    #Starting HomePage Steps section Locators
    StepsSection_Text = (By.XPATH, '//p[contains(text()," Making Buying NFTs a Simple Thing ")]')
    Step_one_Text = (By.XPATH, '//div[contains(text(), " Connect Your Wallet ")]')
    Step_two_Text = (By.XPATH, '//div[contains(text(), " Select Your NFT ")]')
    Step_three_Text = (By.XPATH, '//div[contains(text(), " Checkout With Card ")]')
    #Ending HomePage Steps section Locators

    #Starting Top Tredning Section Locators
    Top_trending_Text = (By.XPATH, '//div[contains(@class, "text-scroll-div")]')
    Top_Trending_nfts = (By.XPATH, '//div[contains(@class, "image mt-12")]')

    #Ending Top Tredning section Locators
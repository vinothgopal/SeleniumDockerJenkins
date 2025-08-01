import pytest
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.firefox.service import Service as FirefoxService
import os

@pytest.fixture(scope="module")
def driver(request):
    browser_name = os.environ.get('BROWSER', 'chrome').lower()
    
    if browser_name == 'chrome':
        options = webdriver.ChromeOptions()
        options.add_argument('--headless')
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        driver_path = '/usr/bin/chromedriver'
        service = ChromeService(executable_path=driver_path)
        driver = webdriver.Chrome(service=service, options=options)
    elif browser_name == 'firefox':
        options = webdriver.FirefoxOptions()
        options.add_argument('--headless')
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        driver_path = '/usr/bin/geckodriver'
        service = FirefoxService(executable_path=driver_path)
        driver = webdriver.Firefox(service=service, options=options)
    else:
        raise ValueError(f"Unsupported browser: {browser_name}")

    yield driver
    driver.quit()

def test_verify_title(driver):
    url = os.environ.get('URL', 'https://www.google.com')
    expected_title = os.environ.get('EXPECTED_TITLE', 'Google')

    driver.get(url)
    actual_title = driver.title

    print(f"\nNavigated to: {url}")
    print(f"Expected Title: '{expected_title}'")
    print(f"Actual Title: '{actual_title}'")
    
    assert actual_title == expected_title, f"Title mismatch. Expected: '{expected_title}', Got: '{actual_title}'"
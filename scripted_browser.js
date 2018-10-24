// Open page
$browser.get("https://mywebsite.com");

// Check if page is correctly loaded
var element = $browser.isElementPresent($driver.By.name("who"))
.then(function(elem){
  if(elem === true){
    console.log("Page did load correctly");
  }
  else {
    assert.fail("Page didn't load correctly");
  }
});

// Type a name in the input field and submit
$browser.findElement($driver.By.name("who")).sendKeys("John Doe");
$browser.findElement($driver.By.name("greet")).click();

//Wait for the page and evaluate presence of H1
$browser.waitForAndFindElement($driver.By.css("h1"), 1000);
var element = isElementPresent($driver.By.css("h1"))
.then(function(elem){
  if(elem === true){
    console.log("Response page loaded");
}
  else {
    assert.fail("Response page slow or broken");
  }
});

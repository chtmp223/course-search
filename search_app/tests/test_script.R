app <- ShinyDriver$new("../")
app$snapshotInit("test_script")

app$setInputs(query = "fundamentals")
app$setInputs(queried = "click")
app$setInputs(num = 30)
app$setInputs(num = 0)
app$setInputs(tabset = "courses")
app$snapshot()

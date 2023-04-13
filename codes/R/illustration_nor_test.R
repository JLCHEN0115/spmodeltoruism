# demonstration for the over-rejection behavior of the normality tests
# The code below constructs a set of distributions that approach normality 
# but aren't completely normal

x <- replicate(100, { # generates 100 different tests on each distribution
  c(ols_test_normality(rnorm(10)+c(1,0,2,0,1))[["kolmogorv"]][["p.value"]],   #$
    ols_test_normality(rnorm(100)+c(1,0,2,0,1))[["kolmogorv"]][["p.value"]],  #$
    ols_test_normality(rnorm(1000)+c(1,0,2,0,1))[["kolmogorv"]][["p.value"]], #$
    ols_test_normality(rnorm(5000)+c(1,0,2,0,1))[["kolmogorv"]][["p.value"]]) #$
} # rnorm gives a random draw from the normal distribution
)

rownames(x) <- c("n10","n100","n1000","n5000")

rowMeans(x<0.05) # the proportion of significant deviations

x <- replicate(100, { # generates 100 different tests on each distribution
  c(shapiro.test(rnorm(10)+c(1,0,2,0,1))$p.value,   #$
    shapiro.test(rnorm(100)+c(1,0,2,0,1))$p.value,  #$
    shapiro.test(rnorm(1000)+c(1,0,2,0,1))$p.value, #$
    shapiro.test(rnorm(5000)+c(1,0,2,0,1))$p.value) #$
} # rnorm gives a random draw from the normal distribution
)
rownames(x) <- c("n10","n100","n1000","n5000")

rowMeans(x<0.05) 

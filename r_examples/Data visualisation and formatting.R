#Site with tutorials: https://www.r-statistics.com/2016/11/ggedit-interactive-ggplot-aesthetic-and-theme-editor/

p0 <- iris %>%
  do(., cbind(., r= 1 : nrow(.), id = sample(c("a", "b", "c", "d"), nrow(.),
                                             replace = T))) %>%
  ggplot(aes(x = Sepal.Length, y = Sepal.Width, group = Species)) + 
  geom_point(aes(colour = id)) + geom_line() + facet_grid(Species ~ id)

a <- ggedit(p0)

plot(a)

plot(p0)

p0 %<>% ggedit()

View(p0$theme)

#####Trying to use ggedit with a plot from the circadian stuff

myplot.edited <- ggedit(myplot)


#Another site which discusses themes: http://docs.ggplot2.org/dev/vignettes/themes.html

ggplot(mpg, aes(x = cty, y = hwy, color = factor(cyl))) +
  geom_jitter() +
  labs(
    x = "City mileage/gallon",
    y = "Highway mileage/gallon",
    color = "Cylinders"
  )

p <- ggplot(mpg, aes(x = cty, y = hwy, colour = factor(cyl))) +
  geom_jitter() +
  labs(
    x = "City mileage/gallon",
    y = "Highway mileage/gallon",
    colour = "Cylinders"
  ) +
  scale_colour_brewer(type = "seq", palette = "Oranges")

p

p + labs(title = "Highway vs. city mileage per gallon") +
  theme(
    axis.text = element_text(size = 14),
    legend.key = element_rect(fill = "navy"),
    legend.background = element_rect(fill = "white"),
    legend.position = c(0.14, 0.80),
    panel.grid.major = element_line(colour = "grey40"),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "navy")
  )

p + labs(title = "Highway vs. city mileage per gallon") +
  theme_bw() +
  theme(axis.text = element_text(size = 14),
        legend.key = element_rect(fill = "navy"),
        legend.background = element_rect(fill = "white"),
        legend.position = c(0.14, 0.80),
        panel.grid.major = element_line(colour = "grey40"),
        panel.grid.minor = element_blank()
  )


#I think this is where Maria Nattestad shows how to update themes: https://www.youtube.com/watch?v=w1civKyJGKQ

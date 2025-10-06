# EL Student Outcomes Visualization
# Creates charts for CTE completion analysis by English Learner status

library(ggplot2)
library(dplyr)
library(tidyr)

# Define consistent color scheme for EL categories
el_colors <- c(
  "Never EL" = "#2E86AB",
  "Current EL (<5 years)" = "#A23B72",
  "Current EL (5+ years)" = "#F18F01",
  "Former EL (<5 years)" = "#C73E1D",
  "Former EL (5+ years)" = "#6A994E"
)

# Example data structure (replace with actual data from SQL query)
# This demonstrates the visualization approach with sample data
completion_data <- data.frame(
  EL_Category = c("Never EL", "Current EL (<5 years)", "Current EL (5+ years)", 
                  "Former EL (<5 years)", "Former EL (5+ years)"),
  Total_Students = c(1200, 450, 280, 320, 190),
  Completers = c(480, 135, 84, 144, 95),
  Completion_Rate = c(40.0, 30.0, 30.0, 45.0, 50.0)
)

# Visualization 1: CTE Completion Rates by EL Category
completion_plot <- ggplot(completion_data, 
                          aes(x = reorder(EL_Category, -Completion_Rate), 
                              y = Completion_Rate, 
                              fill = EL_Category)) +
  geom_col(width = 0.7) +
  geom_text(aes(label = sprintf("%0.1f%%\n(%d/%d)", 
                                Completion_Rate, 
                                Completers, 
                                Total_Students)),
            vjust = -0.5, 
            size = 3.5) +
  scale_fill_manual(values = el_colors) +
  scale_y_continuous(limits = c(0, 60),
                     breaks = seq(0, 60, 10),
                     labels = function(x) paste0(x, "%")) +
  labs(
    title = "CTE Completion Rates by English Learner Category",
    subtitle = "High School Students (Grades 9-12)",
    x = "English Learner Category",
    y = "Completion Rate (%)",
    caption = "Note: Anonymized data for demonstration purposes"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
    axis.title = element_text(size = 12, face = "bold"),
    legend.position = "none",
    panel.grid.minor = element_blank()
  )

# Save plot
ggsave("sample_outputs/completion_rates_chart.png", 
       completion_plot, 
       width = 10, 
       height = 6, 
       dpi = 300)

# Visualization 2: Year-over-Year Trends
# Sample trend data
trend_data <- data.frame(
  Year = rep(2020:2024, each = 5),
  EL_Category = rep(c("Never EL", "Current EL (<5 years)", "Current EL (5+ years)", 
                      "Former EL (<5 years)", "Former EL (5+ years)"), 5),
  Completion_Rate = c(
    35, 25, 28, 40, 45,  # 2020
    37, 27, 29, 42, 47,  # 2021
    38, 28, 28, 43, 48,  # 2022
    39, 29, 30, 44, 49,  # 2023
    40, 30, 30, 45, 50   # 2024
  )
)

trend_plot <- ggplot(trend_data, 
                     aes(x = Year, 
                         y = Completion_Rate, 
                         color = EL_Category, 
                         group = EL_Category)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  scale_color_manual(values = el_colors) +
  scale_y_continuous(limits = c(20, 55),
                     breaks = seq(20, 55, 5),
                     labels = function(x) paste0(x, "%")) +
  labs(
    title = "CTE Completion Rate Trends by EL Category",
    subtitle = "Five-Year Trend Analysis (2020-2024)",
    x = "School Year",
    y = "Completion Rate (%)",
    color = "EL Category",
    caption = "Note: Anonymized data for demonstration purposes"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5),
    axis.title = element_text(size = 12, face = "bold"),
    legend.position = "bottom",
    legend.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

# Save trend plot
ggsave("sample_outputs/trends_visualization.png", 
       trend_plot, 
       width = 10, 
       height = 6, 
       dpi = 300)

# Visualization 3: Stacked participation distribution
participation_data <- completion_data %>%
  mutate(
    Completers = Completers,
    Concentrators_Only = round(Total_Students * 0.25 - Completers),
    Non_Participants = Total_Students - Completers - Concentrators_Only
  ) %>%
  select(EL_Category, Completers, Concentrators_Only, Non_Participants) %>%
  pivot_longer(cols = -EL_Category, 
               names_to = "Status", 
               values_to = "Count")

participation_plot <- ggplot(participation_data, 
                            aes(x = EL_Category, 
                                y = Count, 
                                fill = Status)) +
  geom_col(position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(
    values = c("Completers" = "#2E86AB",
               "Concentrators_Only" = "#A23B72", 
               "Non_Participants" = "#E5E5E5"),
    labels = c("Completers", "Concentrators Only", "Non-Participants")
  ) +
  labs(
    title = "CTE Participation Distribution by EL Category",
    x = "English Learner Category",
    y = "Percentage of Students",
    fill = "CTE Status"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )

# Save participation plot
ggsave("sample_outputs/participation_distribution.png", 
       participation_plot, 
       width = 10, 
       height = 6, 
       dpi = 300)

print("Visualizations created successfully!")
print("Files saved to: sample_outputs/")

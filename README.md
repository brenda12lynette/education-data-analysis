# English Learner Outcomes & CTE Analysis

> A comprehensive data analysis examining English Learner student achievement patterns and Career Technical Education (CTE) completion rates in K-12 education.

## 📊 Project Overview

This project analyzes longitudinal student data to understand how English Learner (EL) status and duration impact educational outcomes, specifically focusing on CTE program completion rates. The analysis provides actionable insights for district leadership and informs policy decisions affecting multilingual learners.

## 🎯 Key Questions Addressed

- How do CTE completion rates vary by EL status and years in program?
- What are the achievement patterns for current vs. former EL students?
- How does time to English proficiency correlate with academic outcomes?
- What trends exist in CTE participation among different EL populations?

## 🔧 Technical Approach

### Data Sources
- **Student Demographics Database** (SQL Server): Multi-year student enrollment, EL status, and demographic information
- **Assessment Data**: Standardized test scores (ACT, state assessments)
- **CTE Completion Records**: Career Technical Education program participation and completion data

### Technologies Used
- **SQL**: Complex queries with CTEs, JOINs, and window functions for data extraction and transformation
- **R**: Statistical analysis, data manipulation (dplyr, tidyverse), and visualization (ggplot2)
- **Python**: Data processing and automation scripts
- **Database**: SQL Server with ODBC connections

### Methodology

1. **Data Integration**
   - Connected to district data warehouse using ODBC
   - Merged multiple data sources (demographics, assessments, CTE records)
   - Implemented data quality checks and validation rules

2. **Student Categorization**
   - Developed classification logic for EL status:
     - Current EL (< 5 years)
     - Current EL (5+ years)
     - Former EL/Fluent (< 5 years since exit)
     - Former EL/Fluent (5+ years since exit)
     - Never EL
   - Tracked longitudinal student trajectories across multiple school years

3. **Statistical Analysis**
   - Calculated completion rates by student group
   - Performed trend analysis across academic years
   - Analyzed demographic subgroup patterns
   - Generated visualizations for stakeholder presentations

## 📈 Key Features

- **Longitudinal Tracking**: Multi-year analysis tracking students from 8th grade through 12th grade
- **Demographic Analysis**: Breakdowns by ethnicity, grade level, school type, and special populations
- **Automated Reporting**: R scripts generate reproducible reports and visualizations
- **Data Pipeline**: End-to-end workflow from SQL extraction to executive-ready dashboards

## 🎨 Sample Visualizations

The analysis produces several key visualizations:
- CTE completion rates by EL category (bar charts)
- Year-over-year trends (line graphs)
- Participation distribution (stacked bar charts)
- Demographic breakdown dashboards

*Note: Actual student data is confidential. Sample visualizations use anonymized/aggregated data.*

## 💡 Impact

This analysis directly informed:
- **Superintendent reporting** on EL program effectiveness
- **School Board presentations** on equity and access
- **Policy decisions** regarding EL support services and CTE program design
- **Resource allocation** for multilingual learner support

## 📋 Sample SQL Query

```sql
-- Categorize students by EL status and calculate years in district
WITH EL_Status AS (
    SELECT 
        STD_NUMBER,
        SYE,
        GRADE_LVL_NUMBER,
        ELL_FLAG,
        ELL_LVL,
        CASE 
            WHEN ETH_RACE = 'African American/Black' THEN 'Black'
            WHEN ETH_RACE = 'Native American/Alaskan Native' THEN 'Indigenous People'
            WHEN ETH_RACE = 'Hawaiian/Pacific Islander' THEN 'Pacific Islander'
            ELSE ETH_RACE 
        END AS ETH_RACE,
        FIRST_ENROLLED_US
        -- Calculate years in US schools
        DATEDIFF(year, FIRST_ENROLLED_US, GETDATE()) AS Years_in_District
    FROM STUDENTS_CURRENT
    WHERE CURRENT_ENROLLED_FLAG = 'Yes'
)
SELECT 
    COUNT(DISTINCT STD_NUMBER) as Student_Count,
    CASE 
        WHEN ELL_FLAG = 0 THEN 'Never EL'
        WHEN ELL_FLAG = 1 AND Years_in_District < 5 THEN 'Current EL (<5 years)'
        WHEN ELL_FLAG = 1 AND Years_in_District >= 5 THEN 'Current EL (5+ years)'
        ELSE 'Former EL'
    END AS EL_Category
FROM EL_Status
GROUP BY 
    CASE 
        WHEN ELL_FLAG = 0 THEN 'Never EL'
        WHEN ELL_FLAG = 1 AND Years_in_District < 5 THEN 'Current EL (<5 years)'
        WHEN ELL_FLAG = 1 AND Years_in_District >= 5 THEN 'Current EL (5+ years)'
        ELSE 'Former EL'
    END
ORDER BY Student_Count DESC;
```

## 🔒 Data Privacy

All code and examples use anonymized data. Actual student records, personally identifiable information (PII), and school-specific details have been removed to comply with FERPA regulations.

## 📚 Skills Demonstrated

**Technical:**
- Advanced SQL (CTEs, window functions, complex joins)
- R programming for statistical analysis
- Data visualization and dashboard creation
- Database architecture and data pipeline design
- Version control with Git

**Analytical:**
- Longitudinal research design
- Observational causal inference
- Subgroup analysis
- Educational metrics development

**Communication:**
- Executive-level reporting
- Data storytelling for non-technical audiences
- Stakeholder presentations
- Documentation of methodology

## 👩‍🏫 Background

This work was conducted as part of my role as a Research Analyst in K-12 education. My background includes:
- **M.A. in Sociology & Anthropology** with focus on educational equity
- **College-level STEM teaching** (Biological Anthropology)
- **5+ years** analyzing educational outcomes data
- **Expertise** in multilingual learner research and program evaluation

## 📧 Contact

**Brenda Wiebe**
- GitHub: [@brenda-wiebe](https://github.com/brenda12lynette)
- Email: brenda.lynette@gmail.com
- Location: Salt Lake City, UT

## 📄 License

This project structure and code examples are available for educational purposes. Actual student data is confidential and not included in this repository.

---


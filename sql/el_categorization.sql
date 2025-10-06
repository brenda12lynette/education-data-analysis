-- English Learner Student Categorization and Analysis
-- This query categorizes students by EL status and tracks their CTE participation

WITH Student_Demographics AS (
    -- Get current year student demographics with standardized race/ethnicity
    SELECT DISTINCT 
        STD_NUMBER,
        SYE,
        SCH_NUMBER,
        GRADE_LVL_NUMBER,
        STD_GENDER,
        CASE 
            WHEN ETH_RACE = 'African American/Black' THEN 'Black'
            WHEN ETH_RACE = 'Native American/Alaskan Native' THEN 'Indigenous People'
            WHEN ETH_RACE = 'American Indian' THEN 'Indigenous People'
            WHEN ETH_RACE = 'Hawaiian/Pacific Islander' 
                OR ETH_RACE = 'Hawiian/Pacific Islander' THEN 'Pacific Islander'
            ELSE ETH_RACE 
        END AS ETH_RACE,
        ELL_FLAG,
        ELL_LVL,
        SWD_FLAG,
        LOW_INCOME_FLAG,
        FIRST_ENROLLED_US
    FROM [DWH].[ASM].[STUDENT_DEMOGRAPHICS_CSY]
    WHERE CURRENT_ENROLLED_FLAG = 'Yes'
),

EL_Status_Calculation AS (
    -- Calculate years in district and categorize EL status
    SELECT 
        sd.*,
        DATEDIFF(year, sd.FIRST_ENROLLED_US, GETDATE()) AS Years_in_District,
        CASE 
            WHEN sd.ELL_FLAG = 0 THEN 'Never EL'
            WHEN sd.ELL_FLAG = 1 AND DATEDIFF(year, sd.FIRST_ENROLLED_US, GETDATE()) < 5 
                THEN 'Current EL (<5 years)'
            WHEN sd.ELL_FLAG = 1 AND DATEDIFF(year, sd.FIRST_ENROLLED_US, GETDATE()) >= 5 
                THEN 'Current EL (5+ years)'
            ELSE 'Former EL'
        END AS EL_Category
    FROM Student_Demographics sd
),

CTE_Participation AS (
    -- Get CTE completion status from assessment data
    SELECT 
        STD_NUMBER,
        SYE,
        MAX(CASE WHEN CTE_COMPLETER = 1 THEN 1 ELSE 0 END) as Is_Completer,
        MAX(CASE WHEN CTE_CONCENTRATOR = 1 THEN 1 ELSE 0 END) as Is_Concentrator
    FROM [ASSESSMENT_DATA_MART].[Assessment].[CTE_Data]
    GROUP BY STD_NUMBER, SYE
)

-- Final aggregation by EL category
SELECT 
    els.EL_Category,
    COUNT(DISTINCT els.STD_NUMBER) as Total_Students,
    SUM(CASE WHEN cte.Is_Completer = 1 THEN 1 ELSE 0 END) as CTE_Completers,
    SUM(CASE WHEN cte.Is_Concentrator = 1 THEN 1 ELSE 0 END) as CTE_Concentrators,
    CAST(SUM(CASE WHEN cte.Is_Completer = 1 THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(COUNT(DISTINCT els.STD_NUMBER), 0) AS DECIMAL(5,2)) as Completion_Rate,
    AVG(els.Years_in_District) as Avg_Years_in_District
FROM EL_Status_Calculation els
LEFT JOIN CTE_Participation cte 
    ON els.STD_NUMBER = cte.STD_NUMBER 
    AND els.SYE = cte.SYE
WHERE els.GRADE_LVL_NUMBER >= 9  -- Focus on high school students
GROUP BY els.EL_Category
ORDER BY Total_Students DESC;

-- Additional analysis: Breakdown by grade level
SELECT 
    els.EL_Category,
    els.GRADE_LVL_NUMBER,
    COUNT(DISTINCT els.STD_NUMBER) as Student_Count,
    SUM(CASE WHEN cte.Is_Completer = 1 THEN 1 ELSE 0 END) as Completers,
    CAST(SUM(CASE WHEN cte.Is_Completer = 1 THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(COUNT(DISTINCT els.STD_NUMBER), 0) AS DECIMAL(5,2)) as Completion_Rate_Pct
FROM EL_Status_Calculation els
LEFT JOIN CTE_Participation cte 
    ON els.STD_NUMBER = cte.STD_NUMBER 
    AND els.SYE = cte.SYE
WHERE els.GRADE_LVL_NUMBER BETWEEN 9 AND 12
GROUP BY els.EL_Category, els.GRADE_LVL_NUMBER
ORDER BY els.GRADE_LVL_NUMBER, els.EL_Category;

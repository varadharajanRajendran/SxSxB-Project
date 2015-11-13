CREATE TABLE [dbo].[Temp_MMIssueLog]
(
[IssueID] [int] NOT NULL IDENTITY(1, 1),
[SKUNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Catagory] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CategoryID] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Desc] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Impact] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Log] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Temp_MMIssueLog] ADD CONSTRAINT [PK_Temp_MMIssueLog] PRIMARY KEY CLUSTERED  ([IssueID]) ON [PRIMARY]
GO

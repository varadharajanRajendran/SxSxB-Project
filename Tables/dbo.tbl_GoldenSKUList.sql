CREATE TABLE [dbo].[tbl_GoldenSKUList]
(
[Rowid] [int] NOT NULL IDENTITY(1, 1),
[SKU] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_GoldenSKUList] ADD CONSTRAINT [PK_tbl_GoldenSKUList] PRIMARY KEY CLUSTERED  ([Rowid]) ON [PRIMARY]
GO

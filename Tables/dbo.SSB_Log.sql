CREATE TABLE [dbo].[SSB_Log]
(
[Id] [bigint] NOT NULL IDENTITY(1, 1),
[Date] [datetime] NULL,
[Method] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogLevel] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Logger] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Message] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Exception] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[SSB_Log] ADD CONSTRAINT [PK_Table_1] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO

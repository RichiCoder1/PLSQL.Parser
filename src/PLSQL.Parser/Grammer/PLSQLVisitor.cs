using Antlr4.Runtime.Misc;

namespace PLSQL.Grammer
{
    public class PLSQLVisitor : PLSQLBaseVisitor<object>
    {
        public override object VisitUnexpected([NotNull] PLSQLParser.UnexpectedContext context)
        {
            throw new ParseCanceledException("UNEXPECTED_CHAR=" + context.GetText());
        }
    }
}

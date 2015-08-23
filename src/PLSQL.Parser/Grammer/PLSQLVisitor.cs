using Antlr4.Runtime.Misc;
using Antlr4.Runtime.Tree;

namespace PLSQL.Grammer
{
    public class PLSQSafeVisitor<T> : PLSQLBaseVisitor<T>
    {
        public virtual bool TryVisit(IParseTree tree, out T result)
        {
            result = DefaultResult;
            try
            {
                result = Visit(tree);
                return true;
            }
            catch (ParseCanceledException)
            {
                return false;
            }
        }

        public override T VisitUnexpected([NotNull] PLSQLParser.UnexpectedContext context)
        {
            throw new ParseCanceledException("UNEXPECTED_CHAR=" + context.GetText());
        }
    }
}

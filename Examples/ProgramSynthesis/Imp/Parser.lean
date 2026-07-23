import Examples.ProgramSynthesis.Imp.Syntax

namespace ProgramSynthesis.Imp

inductive Token where
  | ident (name : String)
  | natLit (value : Nat)
  | assign
  | semi
  | lparen
  | rparen
  | lbrace
  | rbrace
  | plus
  | minus
  | star
  | eq
  | lt
  | le
  | kwIf
  | kwThen
  | kwElse
  | kwSkip
  | kwTrue
  | kwFalse
  | kwAnd
  | kwOr
  | kwNot
deriving Repr, BEq, DecidableEq, Inhabited

private def isIdentStart (c : Char) : Bool := c.isAlpha || c == '_'

private def isIdentPart (c : Char) : Bool := c.isAlphanum || c == '_'

private def spanChars (p : Char -> Bool) : List Char -> List Char × List Char
  | c :: cs =>
    if p c then
      let (matched, rest) := spanChars p cs
      (c :: matched, rest)
    else
      ([], c :: cs)
  | [] => ([], [])

private def dropLineComment : List Char -> List Char
  | [] => []
  | '\n' :: rest => rest
  | _ :: rest => dropLineComment rest

private def keywordOrIdent (word : String) : Token :=
  match word with
  | "if" => .kwIf
  | "then" => .kwThen
  | "else" => .kwElse
  | "skip" => .kwSkip
  | "true" => .kwTrue
  | "false" => .kwFalse
  | "and" => .kwAnd
  | "or" => .kwOr
  | "not" => .kwNot
  | _ => .ident word

private partial def tokenizeChars : List Char -> Except String (List Token)
  | [] => .ok []
  | c :: cs =>
    if c.isWhitespace then
      tokenizeChars cs
    else if c == '-' && cs matches '-' :: _ then
      match cs with
      | '-' :: rest => tokenizeChars (dropLineComment rest)
      | _ => unreachable!
    else if isIdentStart c then
      let (restWord, tail) := spanChars isIdentPart cs
      let word := String.ofList (c :: restWord)
      do
        let tokens <- tokenizeChars tail
        pure (keywordOrIdent word :: tokens)
    else if c.isDigit then
      let (restDigits, tail) := spanChars Char.isDigit cs
      let digits := String.ofList (c :: restDigits)
      match digits.toNat? with
      | some value => do
          let tokens <- tokenizeChars tail
          pure (.natLit value :: tokens)
      | none => .error s!"invalid numeral: {digits}"
    else
      match c, cs with
      | ':', '=' :: rest => do
          let tokens <- tokenizeChars rest
          pure (.assign :: tokens)
      | '<', '=' :: rest => do
          let tokens <- tokenizeChars rest
          pure (.le :: tokens)
      | ';', rest => do
          let tokens <- tokenizeChars rest
          pure (.semi :: tokens)
      | '(', rest => do
          let tokens <- tokenizeChars rest
          pure (.lparen :: tokens)
      | ')', rest => do
          let tokens <- tokenizeChars rest
          pure (.rparen :: tokens)
      | '{', rest => do
          let tokens <- tokenizeChars rest
          pure (.lbrace :: tokens)
      | '}', rest => do
          let tokens <- tokenizeChars rest
          pure (.rbrace :: tokens)
      | '+', rest => do
          let tokens <- tokenizeChars rest
          pure (.plus :: tokens)
      | '-', rest => do
          let tokens <- tokenizeChars rest
          pure (.minus :: tokens)
      | '*', rest => do
          let tokens <- tokenizeChars rest
          pure (.star :: tokens)
      | '=', rest => do
          let tokens <- tokenizeChars rest
          pure (.eq :: tokens)
      | '<', rest => do
          let tokens <- tokenizeChars rest
          pure (.lt :: tokens)
      | _, _ => .error s!"unexpected character: {c}"

def tokenize (source : String) : Except String (List Token) :=
  tokenizeChars source.toList

abbrev ParseResult (alpha : Type) := Except String (alpha × List Token)

abbrev Parser (alpha : Type) := List Token -> Except String (alpha × List Token)

instance : Monad Parser where
  pure value := fun tokens => .ok (value, tokens)
  bind parser next := fun tokens => do
    let (value, rest) <- parser tokens
    next value rest

mutual

private partial def expectRParen : Parser Unit
  | .rparen :: rest => .ok ((), rest)
  | _ => .error "expected ')'"

private partial def expectRBrace : Parser Unit
  | .rbrace :: rest => .ok ((), rest)
  | _ => .error "expected '}'"

private partial def parseAFactor : Parser AExpr
  | .ident name :: rest => .ok (.var name, rest)
  | .natLit value :: rest => .ok (.const value, rest)
  | .lparen :: rest => do
      let (expr, rest') <- parseAExpr rest
      let (_, rest'') <- expectRParen rest'
      pure (expr, rest'')
  | _ => .error "expected arithmetic expression"

private partial def parseATermRest (lhs : AExpr) : Parser AExpr
  | .star :: rest => do
      let (rhs, rest') <- parseAFactor rest
      parseATermRest (.mul lhs rhs) rest'
  | tokens => .ok (lhs, tokens)

private partial def parseATerm : Parser AExpr := fun tokens => do
  let (lhs, rest) <- parseAFactor tokens
  parseATermRest lhs rest

private partial def parseAExprRest (lhs : AExpr) : Parser AExpr
  | .plus :: rest => do
      let (rhs, rest') <- parseATerm rest
      parseAExprRest (.add lhs rhs) rest'
  | .minus :: rest => do
      let (rhs, rest') <- parseATerm rest
      parseAExprRest (.sub lhs rhs) rest'
  | tokens => .ok (lhs, tokens)

private partial def parseAExpr : Parser AExpr := fun tokens => do
  let (lhs, rest) <- parseATerm tokens
  parseAExprRest lhs rest

private partial def parseBAtom : Parser BExpr
  | .kwTrue :: rest => .ok (.tt, rest)
  | .kwFalse :: rest => .ok (.ff, rest)
  | .kwNot :: rest => do
      let (expr, rest') <- parseBAtom rest
      pure (.not expr, rest')
  | .lparen :: rest => do
      let (expr, rest') <- parseBExpr rest
      let (_, rest'') <- expectRParen rest'
      pure (expr, rest'')
  | tokens => do
      let (lhs, rest) <- parseAExpr tokens
      match rest with
      | .eq :: rest' =>
        let (rhs, rest'') <- parseAExpr rest'
        pure (.eq lhs rhs, rest'')
      | .lt :: rest' =>
        let (rhs, rest'') <- parseAExpr rest'
        pure (.lt lhs rhs, rest'')
      | .le :: rest' =>
        let (rhs, rest'') <- parseAExpr rest'
        pure (.le lhs rhs, rest'')
      | _ => .error "expected boolean comparison"

private partial def parseBAndRest (lhs : BExpr) : Parser BExpr
  | .kwAnd :: rest => do
      let (rhs, rest') <- parseBAtom rest
      parseBAndRest (.and lhs rhs) rest'
  | tokens => .ok (lhs, tokens)

private partial def parseBAnd : Parser BExpr := fun tokens => do
  let (lhs, rest) <- parseBAtom tokens
  parseBAndRest lhs rest

private partial def parseBExprRest (lhs : BExpr) : Parser BExpr
  | .kwOr :: rest => do
      let (rhs, rest') <- parseBAnd rest
      parseBExprRest (.or lhs rhs) rest'
  | tokens => .ok (lhs, tokens)

private partial def parseBExpr : Parser BExpr := fun tokens => do
  let (lhs, rest) <- parseBAnd tokens
  parseBExprRest lhs rest

private partial def parseSimpleStmt : Parser Stmt
  | .kwSkip :: rest => .ok (.skip, rest)
  | .ident name :: .assign :: rest => do
      let (expr, rest') <- parseAExpr rest
      pure (.assign name expr, rest')
  | .kwIf :: rest => do
      let (cond, rest') <- parseBExpr rest
      match rest' with
      | .kwThen :: restThen =>
        let (thenBranch, restAfterThen) <- parseStmt restThen
        match restAfterThen with
        | .kwElse :: restElse =>
          let (elseBranch, restAfterElse) <- parseStmt restElse
          pure (.ite cond thenBranch elseBranch, restAfterElse)
        | _ => .error "expected 'else'"
      | _ => .error "expected 'then'"
  | .lbrace :: rest => do
      let (body, rest') <- parseStmt rest
      let (_, rest'') <- expectRBrace rest'
      pure (body, rest'')
  | _ => .error "expected statement"

private partial def parseStmtRest (lhs : Stmt) : Parser Stmt
  | .semi :: rest => do
      let (rhs, rest') <- parseStmt rest
      pure (.seq lhs rhs, rest')
  | tokens => .ok (lhs, tokens)

private partial def parseStmt : Parser Stmt := fun tokens => do
  let (lhs, rest) <- parseSimpleStmt tokens
  parseStmtRest lhs rest

end

def parseProgram (source : String) : Except String Stmt := do
  let tokens <- tokenize source
  let (stmt, rest) <- parseStmt tokens
  match rest with
  | [] => pure stmt
  | _ => .error s!"unexpected trailing tokens: {repr rest}"

end ProgramSynthesis.Imp

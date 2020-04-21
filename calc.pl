#! /usr/bin/perl -w
use strict;
use Safe;            # 危険な関数は実行できないようにする
use Math::Complex;   # 複素数とそれに関連する数学的な関数

################################################################################
################################################################################
# Last update ... 2009/12/29

################################################################################
################################################################################
my @line = @ARGV;
if (@line >= 1 and !($line[0] =~ /^-big$/)) {
    my $line = "@line";
    # $lineをperl_programとして評価
    print "\n・$line = ",eval("$line"),"\n\n";

} elsif (@line >= 2 and $line[0] =~ /^-big$/) {
    my $big_option = shift(@line);
    my $line = "@line";
    # $lineをperl_programとして評価
    # use bignumを使用
    print "\n・$line = ",eval("use bignum; $line"),"\n\n";

} else {
    &usage;
}


################################################################################
################################ subroutine ####################################

### Usage ######################################################################
sub usage {
    open(USAGE, '> calc.pl.hlp') or die "$!";
    print USAGE <<"EOD";
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Overview:
 command lineからのexpressionを、perl programとして実行。
  * "use Math::Complex;"を使用。
  * 一部の関数や表現は内部subroutineで計算。

Note:
 ※ 式中に、"(", ")", "*" のどれかでもある場合、式全体を\" \"で囲む。
 ※ 三角関数はrad単位。
 ※ 逆三角関数は主値に相当する値を返す。指定された引数が関数の定義域から
    外れている場合、undefを返す。
 ※ 一部の関数で、引数が定義域内であるにも関わらずundefを返すことがある。
    通常この現象は、定義域の境界に極めて近い部分において、または非常に
    大きいか非常に小さい引数を与えた場合にのみ発生する。
    多くの場合その原因は、他の三角関数や指数関数を使用して関数を評価する際に、
    内部的に1e20に1を加える等の演算を行なってしまうことにある。
    このような場合、"-big" optionを付けると良い。
 ※ 一部の関数で、"-big" optionを付けると計算できない事がある。
　　その場合は、"-big" optionを外せば計算できる。

Expression:
 ・+,-,*,\/    ：加減乗除
 ・%          ：割り算の余り
 ・**         ：冪乗
 ・sqrt()     ：平方根
 ・ln(),log() ：自然対数
 ・log10()    ：常用対数
 ・exp()      ：底がネイピア数の指数
 ・e          ：ネイピア数: exp(1)
 ・pi         ：円周率:π
 ・i          ：虚数:i
 ・sin()      ：正弦(sine)
 ・cos()      ：余弦(cosine)
 ・tan()      ：引数の実数値に対する正接（tangent）
 ・sec()      ：引数の実数値に対する正割（secant）
 ・csc()      ：引数の実数値に対する余割（cosecant）
 ・cot()      ：引数の実数値に対する余接（cotangent）
 ・asin()     ：引数の実数値に対する逆正弦（arcsine）
 ・acos()     ：引数の実数値に対する逆余弦（arccosine）
 ・atan()     ：引数の実数値に対する逆正接（arctangent）
 ・asec()     ：引数の実数値に対する逆正割（arcsecant）
 ・acsc()     ：引数の実数値に対する逆余割（arccosecant）
 ・acot()     ：引数の実数値に対する逆余接（arctangent）
 ・sinh()     ：引数の実数値に対する双曲線正弦（hyperbolic_sine）
 ・cosh()     ：引数の実数値に対する双曲線余弦（hyperbolic_cosine）
 ・tanh()     ：引数の実数値に対する双曲線正接（hyperbolic_tangent）
 ・sech()     ：引数の実数値に対する双曲線正割（hyperbolic_secant）
 ・csch()     ：引数の実数値に対する双曲線余割（hyperbolic_cosecant）
 ・coth()     ：引数の実数値に対する双曲線余接（hyperbolic_cotangent）
 ・asinh()    ：引数の実数値に対する逆双曲線正弦(arc_hyperbolic_sine)
 ・acosh()    ：引数の実数値（正の値に限る）に対する
                逆双曲線余弦(arc_hyperbolic_cosine)
 ・atanh()    ：引数の実数値に対する逆双曲線正接(arc_hyperbolic_tangent)
 ・asech()    ：引数の実数値（正の値に限る）に対する
                逆双曲線正割(arc_hyperbolic_secant)
 ・acsch()    ：引数の実数値に対する逆双曲線余割(arc_hyperbolic_cosecant)
 ・acoth()    ：引数の実数値に対する逆双曲線余接(arc_hyperbolic_cotangent)
 ・fact()     ：factorial(階乗):n!
 ・perm( , )  ：permutation(順列):nPr
 ・comb( , )  ：combination(組み合わせ):nCr
 ・reperm( , )：repeated_permutation(重複順列):nΠr
 ・recomb( , )：repeated_combination(重複組み合わせ):nHr
 ・abs()      ：絶対値
 ・int()      ：少数部分を切捨てて整数部を返す
 ・rand()     ：[0,指定した数)の乱数発生
 ・oct()      ：8進数から 10進数への変換
 ・hex()      ：16進数から 10進数への変換
 ・mean( , , ,...) : 全引数の相加平均

  ...その他いろいろ。

Usage:
 ・Calc with normal:
    \$ calc.pl "expression"

 ・Calc with "use bignum":
    \$ calc.pl -big "expression"
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
EOD
    close(USAGE);
    system("more calc.pl.hlp");
    system("rm -f calc.pl.hlp");
    exit;
}

### napier number e ############################################################
sub e() {  # 引数をとらない
    my $e = exp(1);
    return $e;
}

### factorial(階乗) ############################################################
# n!
sub fact {
    my ($n) = @_;
    if ($n<0 or $n =~ /\.\d+|\D+/) {
	return "none";
    }
    my $fact = 1;
    while ($n>0) {
	$fact *= $n;
	$n--;
    }
    return $fact;
}

### permutation(順列) ##########################################################
# 異なるｎ個から順序を考えてｒ個を選ぶ順列の個数：nＰｒ
sub perm {
    my ($n,$r) = @_;
    if ($n<0 or $r<0 or $n<$r or $n =~ /\.\d+|\D+/ or $r =~ /\.\d+|\D+/) {
	return "none";
    }
    return &fact($n)/&fact($n - $r);
}

### combination(組み合わせ) ####################################################
# 異なるｎ個から順序を考えずにｒ個を選ぶ組み合わせの個数：ｎＣｒ
sub comb {
    my ($n,$r) = @_;
    if ($n<0 or $r<0 or $n<$r or $n =~ /\.\d+|\D+/ or $r =~ /\.\d+|\D+/) {
	return "none";
    }
    return &perm($n,$r)/&fact($r);
}

### repeated_permutation(重複順列) #############################################
# 異なるｎ種類から順序を考えてｒ個を選ぶ重複順列の個数：ｎΠｒ
sub reperm {
    my ($n,$r) = @_;
    if ($n<0 or $r<0 or $n =~ /\.\d+|\D+/ or $r =~ /\.\d+|\D+/) {
	return "none";
    }
    return $n**$r;
}

### repeated_combination(重複組み合わせ) #######################################
# 異なるｎ種類から順序を考えずにｒ個を選ぶ重複組み合わせの個数：ｎＨｒ
sub recomb {
    my ($n,$r) = @_;
    if ($n<0 or $r<0 or $n =~ /\.\d+|\D+/ or $r =~ /\.\d+|\D+/) {
	return "none";
    }
    return &comb($n+$r+1,$r);
}

### Calc unweighted mean & error ###############################################
sub mean {
    my (@data) = @_;

    my $sum = 0;
    foreach my $xi (@data) {
	$sum += $xi;
    }
    my $mean = $sum/@data;

    return $mean;
}

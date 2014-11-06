class Benchmark {
  has Bool $.debug     = False;
  has Int  $.min_count = 4;
  has Rat  $.min_cpu   = 0.04;
  has Str  $.format    = '5.2f';
  has Str  $.style     = 'auto';

  method timediff($a, $b){
    my $r = Array.new;
    for 0..max($a.end,$b.end) -> $i {
      $r.push(($a[$i] // 0) - ($b[$i] // 0));
    }
    return $r;
  }

  method timesum($a, $b){
    my $r = Array.new;
    for 0..max($a.end,$b.end) -> $i {
      $r.push(($a[$i] // 0) - ($b[$i] // 0));
    }
    return $r;
  }

  method timestr($t, $style = $.style, $format = $.format){
    my ($r , $pu, $ps, $cu, $cs, $n) = $t;
    my ($pt, $ct, $tt);
    my $s = "$style";
    my $f = '%2d';
    $pu = $pu // 0;
    $ps = $ps // 0;
    $cs = $cs // 0;
    $cu = $cu // 0;
    $s = sprintf("$f wallclock secs (%%$f usr %%$f sys + %%$f cusr %%$f csys = %%$f CPU)",
                 $r//0,$pu,$ps,$cu,$cs,$tt//0) if $style eq ('all'|'auto');
    $s = sprintf("$f wallclock secs (%%$f usr %%$f sys = %%$f CPU)",
                 $r//0,$pu,$ps,$cu,$cs,$tt//0) if $style eq 'noc';
    $s = sprintf("$f wallclock secs (%%$f cusr %%$f csys = %%$f CPU)",
                 $r//0,$pu,$ps,$cu,$cs,$tt//0) if $style eq 'nop';
    my $elapsed = $cu+$cs+$pu+$ps;
    $elapsed    = $cu+$cs if $style eq 'nop';
    $elapsed    = $ps+$pu if $style eq 'noc';
    $s ~= sprintf(" \@ %$f/s (n=$n)", $n/$elapsed) if $n && $elapsed;
    return $s;
  }

  method timedebug($msg,$t){
    $*ERR.say: "$msg {$.timestr($t);}" if $.debug;
  }

  method runloop(Int $n, $c){
    die "Negative loop count ($n)" if $n < 0;
    my ($t0, $t1, $td);
    my $subcode = "sub \{ for (1..$n) \{ \$c; \}; \}";
    my $tbase   = now;
    while (($t0 = now) == $tbase) { };
    &($subcode.EVAL)();
    $t1 = now;
    $td = $.timediff([$t1], [$t0]);
    return $td;
  }

  method timeit(Int $n, $c) {
    my ($wn, $wc, $wd);
    $*ERR.say: "timeit $n {$c.gist}" if $.debug;
    $wn    = $.runloop($n, $c);
    $wn[5] = 0;
    $wc    = $.runloop($n, $c);
    $wd    = $.timediff($wc, $wn);
    $.timedebug('timeit: ', $wc);
    $.timedebug('      - ', $wn);
    $.timedebug('      = ', $wd);
    return $wd;
  }
};

sub mytime { return now; }


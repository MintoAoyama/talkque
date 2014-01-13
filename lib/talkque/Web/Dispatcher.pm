package talkque::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use 5.10.0;

use Amon2::Web::Dispatcher::RouterBoom;

use Config::Pit;
use Net::Google::Spreadsheets;
use Data::Dumper;
use Time::Piece;

any '/' => sub {
    my ($c) = @_;

    # debug
    # say 'pit_get( \'google.com\' ) = '.Dumper( pit_get( 'google.com' ) );
    # say 'config->{spreadsheet}->{key} = '.$c->config->{spreadsheet}->{key};
    # say 'config->{spreadsheet}->{title} = '.$c->config->{spreadsheet}->{title};

    my $t = localtime;
    # say $t;
    my $spreadsheet = $c->config->{spreadsheet};
    # my $label_pubdate = $spreadsheet->{label}->{pub_date};

	my $service = Net::Google::Spreadsheets->new(pit_get('google.com'));
	my $sheet = $service->spreadsheet(
        { key => $spreadsheet->{key}, }
    );
    my $worksheet = $sheet->worksheet(
        { title => $spreadsheet->{title}, }
    );
    my @rows = $worksheet->rows;
    my @prgrms_ftr = ();
    my @prgrms_pst = ();

    # 発表日リスト 作成
    my @dates_ftr;
    my @dates_pst;
    if ( @rows ) {
        for my $row ( @rows ) {
            # if ( $row->{content}->{'発表日'} eq '12/13/2013' ) {
            if ( $row->{content}->{'発表日'} ne '' ) {
                # say $row->{content}->{'発表日'};
                my $date = localtime->strptime( $row->{content}->{'発表日'}, '%m/%d/%Y' );
                my $str_date = $date->strftime( '%Y-%m-%d' );
                # 
                $date = Time::Piece->strptime($str_date.' '.$c->config->{endtime}, '%Y-%m-%d %H:%M');
                # my $date = $row->{content}->{'発表日'};
                # 重複削除しながら、現在日を基準に発表リストを作成
                if ( $t < $date ) {
                    # 予定されている発表日
                    push( @dates_ftr, $date ) if ( ! grep {$_ eq $date} @dates_ftr );
                } else {
                    # 過去の発表日
                    push( @dates_pst, $date ) if ( ! grep {$_ eq $date} @dates_pst );
                }
            }
        }
    }
    # 昇順ソート
    # say '---';
    @dates_ftr = sort {$a <=> $b} @dates_ftr;
    for ( @dates_ftr ) {
        # say $_;
    }
    # say '---';
    if ( @dates_ftr ) {
        my $vol = @dates_pst;
        for my $date_ftr ( @dates_ftr ) {
            my $str_date_ftr = $date_ftr->strftime( '%-m/%e/%Y' );
            # say $str_date_ftr;
            my @prgrm_ftr;
            if ( @rows ) {
                for my $row ( @rows ) {
                    # say '発表日 ='.$row->{content}->{'発表日'};
                    push( @prgrm_ftr, { vol => $vol, row => $row, date => $date_ftr->strftime( '%Y/%-m/%e' ) } ) if ( $row->{content}->{'発表日'} eq $str_date_ftr );
                }
            }
            push ( @prgrms_ftr, \@prgrm_ftr ) if ( @prgrm_ftr );
            $vol = $vol + 1;
        }
    }

    # say Dumper ( @prgrms_ftr );

    return $c->render( 'index.tx' => {
        index => 'active',
        spreadsheet_key => $spreadsheet->{key},
        prgrms_ftr => \@prgrms_ftr,
    } );
};

any '/archives' => sub {
    my ($c) = @_;

    # debug
    # say 'pit_get( \'google.com\' ) = '.Dumper( pit_get( 'google.com' ) );
    # say 'config->{spreadsheet}->{key} = '.$c->config->{spreadsheet}->{key};
    # say 'config->{spreadsheet}->{title} = '.$c->config->{spreadsheet}->{title};

    my $t = localtime;
    # say $t;
    my $spreadsheet = $c->config->{spreadsheet};
    # my $label_pubdate = $spreadsheet->{label}->{pub_date};

    my $service = Net::Google::Spreadsheets->new(pit_get('google.com'));
    my $sheet = $service->spreadsheet(
        { key => $spreadsheet->{key}, }
    );
    my $worksheet = $sheet->worksheet(
        { title => $spreadsheet->{title}, }
    );
    my @rows = $worksheet->rows;
    my @prgrms_pst = ();

    # 発表日リスト 作成
    my @dates_pst;
    if ( @rows ) {
        for my $row ( @rows ) {
            # if ( $row->{content}->{'発表日'} eq '12/13/2013' ) {
            if ( $row->{content}->{'発表日'} ne '' ) {
                # say $row->{content}->{'発表日'};
                my $date = localtime->strptime( $row->{content}->{'発表日'}, '%m/%d/%Y' );
                my $str_date = $date->strftime( '%Y-%m-%d' );
                # say 'aaaa = '.$str_date.' '.$c->config->{endtime};
                $date = localtime->strptime($str_date.' '.$c->config->{endtime}, '%Y-%m-%d %H:%M');
                # my $date = $row->{content}->{'発表日'};
                # 重複削除しながら、現在日を基準に発表リストを作成
                if ( $t >= $date ) {
                    # 過去の発表日
                    # say '$t = '.$t;
                    # say '$date = '.$date;
                    push( @dates_pst, $date ) if ( ! grep {$_ eq $date} @dates_pst );
                }
            }
        }
    }
    # 昇順ソート
    # say '---';
    @dates_pst = sort {$a <=> $b} @dates_pst;
    for ( @dates_pst ) {
        # say $_;
    }
    # say '---';
    if ( @dates_pst ) {
        my $vol = 0;
        for my $date_pst ( @dates_pst ) {
            my $str_date_pst = $date_pst->strftime( '%-m/%e/%Y' );
            $str_date_pst =~ s/ //g;
            # say '$str_date_pst = '.$str_date_pst;
            my $dsp_date_pst = $date_pst->strftime( '%Y/%-m/%e' );
            $dsp_date_pst =~ s/ //g;
            my @prgrm_pst;
            if ( @rows ) {
                for my $row ( @rows ) {
                    # say '発表日 ='.$row->{content}->{'発表日'};
                    push( @prgrm_pst, { vol => $vol, row => $row, date => $dsp_date_pst } ) if ( $row->{content}->{'発表日'} eq $str_date_pst );
                }
            }
            push ( @prgrms_pst, \@prgrm_pst ) if ( @prgrm_pst );
            $vol = $vol + 1;
        }
    }

    # for my $prgrm ( @prgrms_pst ) {
    #     say $prgrm->[0]->{'date'};
    # }

    return $c->render( 'archive.tx' => {
        archives => 'active',
        spreadsheet_key => $spreadsheet->{key},
        prgrms_pst => \@prgrms_pst,
    } );
};

# post '/account/logout' => sub {
#     my ($c) = @_;
#     $c->session->expire();
#     return $c->redirect('/');
# };

1;

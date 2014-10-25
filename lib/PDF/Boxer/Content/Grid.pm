package PDF::Boxer::Content::Grid;
{
  $PDF::Boxer::Content::Grid::VERSION = '0.002';
}
use Moose;
# ABSTRACT: a box of rows with column widths aligned

use namespace::autoclean;

extends 'PDF::Boxer::Content::Column';

sub update_children{
  my ($self) = @_;
  $self->update_kids_size     if $self->size_set;
  $self->update_kids_position if $self->position_set;
  $self->update_grand_kids;
  foreach my $kid (@{$self->children}){
    $kid->update;
  }
  return 1;
}

sub update_kids_position{
  my ($self) = @_;
  my $kids = $self->children;
  if (@$kids){
    my $top = $self->content_top;
    my $left = $self->content_left;
    foreach my $kid (@$kids){
      $kid->move($left, $top);
      $top -= $kid->margin_height;
    }
  }
  return 1;
}

sub update_kids_size{
  my ($self) = @_;

  my ($width, $height) = $self->get_default_size;

  my $kids = $self->children;

  if (@$kids){

    my $space = $self->height - $height;
    my ($has_grow,$grow,$grow_all);
    my ($space_each);
    if ($space < $height/10){
      foreach my $kid (@$kids){
        $has_grow++ if $kid->grow;
      }
      if (!$has_grow){
        $grow_all = 1;
        $has_grow = @$kids;
      }
      $space_each = int($space/$has_grow);
    }

    my $kwidth = $self->content_width;

    foreach my $kid (@$kids){
      my $kheight = $kid->margin_height;
      if ($grow_all || $kid->grow){
        $kheight += $space_each;
      }
      $kid->set_margin_size($kwidth, $kheight);
    }

  }

  return 1;
}

sub update_grand_kids{
  my ($self) = @_;

  my ($width, $height) = $self->get_default_size;

  my $kids = $self->children;

  if (@$kids){
    # calculate minumum widths of cells (kids)
    my @row_highs;
    foreach my $row (@$kids){
      my @cells;
      foreach my $cell (@{$row->children}){
        push(@cells, $cell->margin_width);
      }
      my $idx = 0;
      foreach my $val (@cells){
        $row_highs[$idx] = $val if $val > ($row_highs[$idx] || 0);
        $idx++;
      }
    }

    foreach (@$kids){
      $_->set_kids_minimum_width({ min_widths => \@row_highs });
    }
  }

  return 1;
}



__PACKAGE__->meta->make_immutable;

1;


__END__
=pod

=head1 NAME

PDF::Boxer::Content::Grid - a box of rows with column widths aligned

=head1 VERSION

version 0.002

=head1 AUTHOR

Jason Galea <lecstor@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Jason Galea.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


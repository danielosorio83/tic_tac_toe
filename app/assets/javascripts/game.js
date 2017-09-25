$(document).on('click', "td.active", function(){
  var that = $(this);
  that.removeClass('active');
  $("#loader").show();
  var grid = $("#grid");
  $.ajax({
    url: GAME_URL,
    method: 'PUT',
    dataType: 'script',
    data: {
      size: grid.data('size'),
      player: PLAYER_1,
      table: parse_table(grid),
      position: that.data('position')
    }
  }).done(function(){
    $("#loader").hide();
  });
});


function display_message(message, alert){
  $("#game").before("<div class=\"alert alert-" + alert + " fade show\" role=\"alert\">" + message + "</div>");
  setTimeout(function(){
    $(".alert").alert('close');
  }, 3000);
}

function parse_table(grid){
    var table = [];
    grid.find('.cell').each(function(){
      var cell_value = $(this).text();
      var cell = (cell_value == PLAYER_1 || cell_value == PLAYER_2) ? cell_value : NEUTRO;
      table.push(cell);
    });
    return table;
  }

var player_grid_positions;

function show_background(player){
  var grid = $("#grid");
  var winning_line = get_winning_cells(player, grid);
  $.each(winning_line, function(i, position){
    grid.find("[data-position=" + position + "]").addClass('bg-warning');
  });
}

function get_winning_cells(player, grid){
  var size = window.grid.data('size');
  var grid_size = size * size;
  var player_grid = grid.find('.cell.' + player);
  player_grid_positions = $.map(player_grid, function(cell){ return $(cell).parent().data('position') });
  var first_position = player_grid.first().parent().data('position');
  // Verticual Search
  if (first_position < size){
    var winning_line = get_winning_positions(first_position, grid_size, size)
    if (winning_line.length == size){
      return winning_line;
    }
  }
  // Horizontal Search
  if (first_position % size == 0){
    var winning_line = get_winning_positions(first_position, first_position + size, 1)
    if (winning_line.length == size){
      return winning_line;
    } 
  }
  // Diagonally Search
  if (first_position == 0 || first_position == size - 1){
    // Top-left -> Bottom-Right
    var winning_line = get_winning_positions(first_position, grid_size, size + 1)
    if (winning_line.length == size){
      return winning_line;
    }
    // Top-Right -> Bottom-Left
    var winning_line = get_winning_positions(first_position, grid_size, size - 1)
    if (winning_line.length == size){
      return winning_line;
    }
  }
  return [];
}

function get_winning_positions(start, end, increment){
  var positions = [];
  for(var position = start; position < end; position = position + increment){
    if (window.player_grid_positions.indexOf(position) >= 0){
      positions.push(position);
    }
  }
  return positions;
}
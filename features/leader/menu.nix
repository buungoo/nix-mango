{...}: {
  config.leaderMenu = [
    {
      key = "l";
      desc = "Layout";
      submenu = [
        {
          key = "c";
          desc = "Center tile";
          cmd = "mmsg dispatch setlayout,center_tile";
        }
        {
          key = "d";
          desc = "Deck";
          cmd = "mmsg dispatch setlayout,deck";
        }
        {
          key = "f";
          desc = "Fair";
          cmd = "mmsg dispatch setlayout,fair";
        }
        {
          key = "g";
          desc = "Grid";
          cmd = "mmsg dispatch setlayout,grid";
        }
        {
          key = "m";
          desc = "Monocle";
          cmd = "mmsg dispatch setlayout,monocle";
        }
        {
          key = "r";
          desc = "Right Tile";
          cmd = "mmsg dispatch setlayout,right_tile";
        }
        {
          key = "s";
          desc = "Scroller";
          cmd = "mmsg dispatch setlayout,scroller";
        }
        {
          key = "t";
          desc = "Tile";
          cmd = "mmsg dispatch setlayout,tile";
        }
        {
          key = "w";
          desc = "Dwindle";
          cmd = "mmsg dispatch setlayout,dwindle";
        }
        {
          key = "D";
          desc = "Vertical Deck";
          cmd = "mmsg dispatch setlayout,vertical_deck";
        }
        {
          key = "F";
          desc = "Vertical fair";
          cmd = "mmsg dispatch setlayout,vertical_fair";
        }
        {
          key = "G";
          desc = "Vertical Grid";
          cmd = "mmsg dispatch setlayout,vertical_grid";
        }
        {
          key = "S";
          desc = "Vertical Scroller";
          cmd = "mmsg dispatch setlayout,vertical_scroller";
        }
        {
          key = "T";
          desc = "Vertical Tile";
          cmd = "mmsg dispatch setlayout,vertical_tile";
        }
      ];
    }
  ];
}

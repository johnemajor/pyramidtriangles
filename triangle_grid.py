from collections import defaultdict, namedtuple
from color import RGBW


##
## Triangle Grid class to represent one strip
##

class TriangleGrid(object):
    def __init__(self, model, n_rows):

        self.model = model
#        from IPython import embed; embed()
        
        self.build_triangle_grid(n_rows)

    def __str__(self):
        return str("ME")

    def __repr__(self):
        print "what is this for?"
#        raise Exception('what is this for?')


    def build_triangle_grid(self,n_rows):
        self.cells = []
        if n_rows < 1:
            raise Exception('row num must be 1+', n_rows)
        if n_rows > 20:
            raise Exception('row num must be <12')
        if len(self.cells) > 0:
            raise Exception('You have already built a triangle grid, clear this one first')

        row_len = 0
        end_cell_id = 0
        cell_id = 0
        end_cell_id = 0

        curr_row = 0
        while curr_row <= n_rows:
            print "Curr Row:", curr_row

            left_set = False
            cells_added = 0
            up_down = 'up'
            l_corner=False
            r_corner=False
            top = False
            if curr_row == n_rows:
                l_corner= True
            else:
                l_corner = False

            is_l_edge = False
            is_r_edge = False
            is_btm_edge = False

            loop_start = True
            while cell_id <= end_cell_id:
                cell_id +=1

                if curr_row == n_rows and cell_id == end_cell_id+1:
                    r_corner = True
                else:
                    r_corner = False

                if curr_row == 0:
                    top =  True
                else:
                    top = False
                if loop_start is True:
                    is_l_edge = True
                else:
                    is_l_edge = False
                
                if cell_id == end_cell_id:
                    is_r_edge = True
                else:
                    is_r_edge = False
                if curr_row == n_rows:
                    is_btm_edge = True
                else:
                    is_btm_edge = False
                cells_added += 1
                print "\t\tCell ID:", cell_id,  curr_row, up_down, top, l_corner, r_corner, is_l_edge, is_r_edge, is_btm_edge
                self.cells.append(TriangleCell(cell_id,  curr_row, up_down, top, l_corner, r_corner, is_l_edge, is_r_edge, is_btm_edge))


                if up_down == 'up':
                    up_down = 'down'
                else:
                    up_down = 'up'
                if l_corner is True:
                    l_corner = False
                loop_start = False
                    
            end_cell_id += 2 + cells_added
            
            curr_row += 1


    def delete_cells(self):
        self.cells = []

    def all_cells(self):
        "Return the list of valid cell IDs"
        return self.cells

    def set_cell(self, cell, color):
        self.model.set_cell(cell, color)

    def set_cells(self, cells, color):
        self.model.set_cells(cells, color)

    def set_all_cells(self, color):
        self.set_cells(self.model.CELL_MAP.keys(), color)

    def clear(self):
        ""
        self.set_all_cells(RGBW(0,0,0,0))
        self.go()

    def go(self):
        self.model.go()

    # convenience methods for grabbing useful parts of the triangle grid
   

class TriangleCell(object):
    def __init__(self,  cell_id,  row, up_down, is_top, l_corner, r_corner, is_l_edge, is_r_edge, is_btm_edge):

        self.id = cell_id
        self.row_num = row
        self.left_edge_cell = is_l_edge
        self.right_edge_cell = is_r_edge
        self.top_cell = is_top
        self.btm_right = r_corner
        self.btm_left = l_corner
        self.pointy_side = up_down
        

#import "@preview/circuiteria:0.2.0"
#import circuiteria: util.colors
#set page(width: auto, height: auto, margin: .5cm)
#set text(font: "0xProto Nerd Font")
#let simple_register(
  x:none,
  y:none,
  w:none,
  h:none,
  fill:none,
  name:none,
  id:"",
  d_width:8,
  q_width:8,
  rst_name:"") = {
  import circuiteria: *
  let q_w;
  let d_w
  if q_width > 1 {q_w = [Q#sub([\[#{q_width - 1}:0\]])]} else {q_w = [Q]}
  if d_width > 1 {d_w = [D#sub([\[#{d_width - 1}:0\]])]} else {d_w = [D]}
  element.block(
        x: x,
        y: y,
        w: w, h: h,
        fill: fill,
        id: id, name:name,
        ports: (
          west : (
            (id:"D",name:d_w),
            (id:"E",name:"E")
            ),
            east : ((id:"Q",name:q_w),),
            north :(
              (id:"clk",clock:true,small:true),
              (id:"rst",name:"rst")
              )
        )
      )
  wire.stub(id+"-port-clk","north")
  wire.stub(id+"-port-rst","north",name: rst_name)
}



= $I^2C$ Peripheral
== Memory Map
#let filled_cell(color_,content)={
  if type(color_) == str{
    table.cell(fill:rgb(color_),content)
  } else if type(color_) == color {
    table.cell(fill:color_,content)
  }
  }
#table(
  columns : (12em,auto),
  align: center + horizon,
  table.header([*Base Address (0x52000)*],filled_cell(colors.green)[*Control Registers*]),
  [BASE + 0x04],filled_cell(colors.green)[RINIT],
  [BASE + 0x08],filled_cell(colors.green)[RNEXT],
  [BASE + 0x0C],filled_cell(colors.green)[RSTOP],
  [BASE + 0x10],filled_cell(colors.green)[RADDRA],
  [BASE + 0x14],filled_cell(colors.green)[RMACK],
  [],filled_cell(colors.blue)[*Status Registers*],
  [BASE + 0x18],filled_cell(colors.blue)[RIUSE],
  [BASE + 0x1C],filled_cell(colors.blue)[RNEEDA],
  [BASE + 0x20],filled_cell(colors.blue)[RBYTEA],
  [BASE + 0x24],filled_cell(colors.blue)[RSACK],
  [],filled_cell("#749BF6")[*Data Registers*],
  [BASE + 0x28],filled_cell("#749BF6")[BUFFSEND],
  [BASE + 0x2C],filled_cell("#749BF6")[BUFFRECEIVE],
)
== Diagram
#circuiteria.circuit({
  import circuiteria: *
  //Write Address Decoder
  element.group(name: [$I^2C$ Peripheral],
  name-anchor: "south" ,{
  element.block(
    x:0,y:0,w:7,h:5,id:"wr_addr_dec",
    name:"Write\nAddress\nDecoder",
    ports: (
      west: (
        (id:"addr_in",name:[addr#sub("[6:0]")]),
        (id:"wr",name:"wr"),
        (id:"cs",name:"cs")
        ),
      east: ((id:"select",name:[s#sub("[5:0]")]),)
    ),
    fill: util.colors.orange
  )
  wire.stub(
    "wr_addr_dec-port-addr_in",
    "west", name:[addr#sub("[31:0]")])
  wire.stub(
    "wr_addr_dec-port-wr",
    "west", name:"wr")
  wire.stub("wr_addr_dec-port-cs",
  "west",name:"cs")
  //CPU Writeable Registers
  element.group(
    id:"writeable_registers",
    stroke: 0pt,{
      simple_register(
        x:(rel:5, to:"wr_addr_dec.east"),
        y: 10, w: 5, h: 3,
        fill: util.colors.green,
        id: "RINIT", name:"RINIT",
        q_width: 1,d_width: 1,
        rst_name: "w_init_clr"
      )
      simple_register(
        x:(rel:5, to:"wr_addr_dec.east"),
        y: 5.5, w: 5, h: 3,
        fill: util.colors.green,
        id: "RNEXT", name:"RNEXT",
        q_width: 1, d_width: 1,
        rst_name: "w_continue_clr"
      )
      simple_register(
        x:(rel:5, to:"wr_addr_dec.east"),
        y:1, w: 5, h: 3,
        fill: util.colors.green,
        id: "RSTOP", name:"RSTOP",
        q_width: 1,d_width: 1,
        rst_name: "w_stop_clr"
        )
      simple_register(
        x:(rel:5, to:"wr_addr_dec.east"),
        y:-3.5, w: 5, h: 3,
        fill: util.colors.green,
        id: "RADDRA", name:"RADDRA"
        )
      simple_register(
        x:(rel:5, to:"wr_addr_dec.east"),
        y:-8, w: 5, h: 3,
        fill: util.colors.green,
        id: "RMACK", name:"RMACK",
        q_width: 1, d_width: 1
        )
      simple_register(
        x:(rel:5, to:"wr_addr_dec.east"),
        y:-12.5, w: 6, h: 3,
        fill: rgb("#749BF6"),
        id: "BUFFSEND", name:"BUFFSEND"
        )
  })
  
  wire.wire("d_in_rinit",
  ((0,6),"RINIT-port-D"),
  style: "zigzag",directed: true, bus: true,
  name:[data_in#sub("[31:0]")],name-pos: "start",
  color : red
  )
  wire.wire("d_in_rnext",
  ((0,6),"RNEXT-port-D"),
  style: "zigzag",directed: true, bus:true,
  color : red
  )
  wire.wire("d_in_rstop",
  ((0,6),"RSTOP-port-D"),
  style: "zigzag",directed: true, bus:true,
  zigzag-ratio: 70%, color : red
  )
  wire.wire("d_in_raddra",
  ((0,6),"RADDRA-port-D"),
  style: "zigzag",directed: true, bus:true,
  zigzag-ratio: 70%, color : red
  )
  wire.wire("d_in_rmack",
  ((0,6),"RMACK-port-D"),
  style: "zigzag",directed: true, bus:true,
  zigzag-ratio: 70%, color : red
  )
  wire.wire("d_in_buffsend",
  ((0,6),"BUFFSEND-port-D"),
  style: "zigzag",directed: true, bus:true,
  zigzag-ratio: 70%, color : red
  )

  wire.wire("wr_addr_dec_s0",
  ("wr_addr_dec-port-select","RINIT-port-E"),
  style: "zigzag", directed: true, bus:true,
  name: "s[0]", name-pos: "end",
  )
  wire.wire("wr_addr_dec_s1",
  ("wr_addr_dec-port-select","RNEXT-port-E"),
  style: "zigzag", directed: true, bus:true,
  name: "s[1]", name-pos: "end",
  )
  wire.wire("wr_addr_dec_s2",
  ("wr_addr_dec-port-select","RSTOP-port-E"),
  style: "zigzag", directed: true, bus:true,
  name: "s[2]", name-pos: "end",
  )
  wire.wire("wr_addr_dec_s3",
  ("wr_addr_dec-port-select","RADDRA-port-E"),
  style: "zigzag", directed: true, bus:true,
  name: "s[3]", name-pos: "end",
  )
  wire.wire("wr_addr_dec_s4",
  ("wr_addr_dec-port-select","RMACK-port-E"),
  style: "zigzag", directed: true, bus:true,
  name: "s[4]", name-pos: "end",
  )
  wire.wire("wr_addr_dec_s5",
  ("wr_addr_dec-port-select","BUFFSEND-port-E"),
  style: "zigzag", directed: true, bus:true,
  name: "s[5]", name-pos: "end",
  )

//I2C Module
  element.block(
    x : (rel:7,to:"RINIT.east"),
    y : (from:"RINIT-port-Q",to:"init_rd"),
    w : 15, h : 12, name:"I2C Module",
    fill : util.colors.pink,id:"i2c_module",
    ports: (
      north : (
        (id:"dummy"),
        (id:"clk", clock:true,small:true),
        (id:"rst", name:"rst"),
        (id:"dummy")),
      south : (
        (id:"SDA_set",name: "SDA_set"),
        (id:"SDA_rd",name:"SDA_rd"),
        (id:"SCL_set", name:"SCL_set")
      ),
      west : (
        (id:"init_rd", name:"init_read"),
        (id:"continue_rd", name:"continue_read"),
        (id:"stop_rd", name:"stop_read"),
        (id:"addr_cmd", name:[address_cmd#sub("[7:0]")]),
        (id:"master_ACK", name:"master_ACK"),
        (id:"data_in", name:[data_in#sub("[7:0]")])
        ),
      east:(
        (id:"init_clr", name:"init_clear"),
        (id:"continue_clr", name:"continue_clear"),
        (id:"stop_clr",name:"stop_clear"),
        (id:"in_use",name:"in_use"),
        (id:"need_action",name:"need_action"),
        (id:"slave_ACK",name:"slave_ACK"),
        (id:"data_avail", name:"data_available"),
        (id:"data_out",name:[data_out#sub("[7:0]")]),
        (id:"reg_select",name:[reg_s#sub("[4:0]")]),
        )
    )
  )
  wire.stub("i2c_module-port-clk","north")
  wire.stub("i2c_module-port-rst","north")

  wire.stub("i2c_module-port-init_clr",
  "east",name:"w_init_clr"
  )
  wire.stub("i2c_module-port-continue_clr",
  "east",name:"w_continue_clr"
  )
  wire.stub("i2c_module-port-stop_clr",
  "east",name:"w_stop_clr"
  )

  wire.wire("w_RINIT_rd",
  ("RINIT-port-Q","i2c_module-port-init_rd"),
  directed: true, name:"w_RINIT_rd",
  name-pos: "end"
  )
  wire.wire("w_RNEXT_rd",
  ("RNEXT-port-Q","i2c_module-port-continue_rd"),
  directed: true, name: "w_RNEXT_rd",
  style: "zigzag", name-pos: "end",
  zigzag-ratio: 20%
  )
  wire.wire("w_RSTOP_rd",
  ("RSTOP-port-Q","i2c_module-port-stop_rd"),
  directed: true, name: "w_RSTOP_rd",
  style: "zigzag", name-pos: "end",
  zigzag-ratio: 30%
  )
  wire.wire("w_addr_cmd",
  ("RADDRA-port-Q","i2c_module-port-addr_cmd"),
  directed: true, name: "w_addr_cmd",
  style: "zigzag", name-pos: "end", bus: true, zigzag-ratio: 40%
  )
  wire.wire("w_MACK",
  ("RMACK-port-Q","i2c_module-port-master_ACK"),
  directed: true, name: "w_MACK",
  style: "zigzag", name-pos: "end", zigzag-ratio: 50%
  )
  wire.wire("w_BUFFSEND",
  ("BUFFSEND-port-Q", "i2c_module-port-data_in"),
  directed: true, name: "w_BUFFSEND",
  style: "zigzag", name-pos: "end",
  bus:true
  )
//Read Only Registers
  element.group(
    id:"read_only_registers",
    stroke:0pt,
    {
      simple_register(
        x:(rel:9,to:("i2c_module.east")),
        y:(from:"i2c_module-port-in_use",to:"D"),
        fill: util.colors.blue,
        w:5,h:3,d_width: 1,q_width: 1,
        name: "RIUSE", id: "RIUSE"
      )
      simple_register(
        x:(rel:0,to:"RIUSE.west"),
        y:(from:"RIUSE.south",to:"rst",rel:-1),
        fill: util.colors.blue,
        w:5,h:3,d_width: 1,q_width: 1,
        name: "RNEEDA", id: "RNEEDA"
      )
      simple_register(
        x:(rel:0,to:"RIUSE.west"),
        y:(from:"RNEEDA.south",to:"rst",rel:-1),
        fill: util.colors.blue,
        w:5,h:3,d_width: 1,q_width: 1,
        name: "RSACK", id: "RSACK"
      )
      simple_register(
        x:(rel:0,to:"RIUSE.west"),
        y:(from:"RSACK.south",to:"rst",rel:-1),
        fill: util.colors.blue,
        w:5,h:3,d_width: 1,q_width: 1,
        name: "RBYTEA", id: "RBYTEA"
      )
      simple_register(
        x:(rel:0,to:"RIUSE.west"),
        y:(from:"RBYTEA.south",to:"rst",rel:-1),
        fill: rgb("#749BF6"),
        w:7,h:3,d_width: 8,q_width: 8,
        name: "BUFFRECEIVE", id: "BUFFRECEIVE"
      )
    }
  )

  wire.wire("w_RIUSE",
  ("i2c_module-port-in_use","RIUSE-port-D"),
  style: "zigzag",
  name:"w_RIUSE",name-pos: "end",
  directed: true
  )
  wire.wire("w_RNEEDA",
  ("i2c_module-port-need_action","RNEEDA-port-D"),
  style: "zigzag",
  name: "w_RNEEDA", name-pos: "end",
  zigzag-ratio: 60%,
  directed: true
  )
  wire.wire("w_RSACK",
  ("i2c_module-port-slave_ACK","RSACK-port-D"),
  style: "zigzag",
  name: "w_RSACK", name-pos: "end",
  directed: true
  )
  wire.wire("w_RBYTEA",
  ("i2c_module-port-data_avail","RBYTEA-port-D"),
  style: "zigzag",
  name: "w_RBYTEA", name-pos: "end",
  zigzag-ratio: 40%,
  directed: true
  )
  wire.wire("w_BUFFRECEIVE",
  ("i2c_module-port-data_out","BUFFRECEIVE-port-D"),
  style: "zigzag",
  name: "w_BUFFRECEIVE", name-pos: "end",
  zigzag-ratio: 30%, bus: true,
  directed: true
  )
  wire.wire("w_i2c_module_reg_s0",
  ("i2c_module-port-reg_select","RIUSE-port-E"),
  style: "zigzag", directed: true,
  zigzag-ratio: 70%, name: "reg_s[0]",
  name-pos: "end",bus: true,
  color : orange
  )
  wire.wire("w_i2c_module_reg_s1",
  ("i2c_module-port-reg_select","RNEEDA-port-E"),
  style: "zigzag", directed: true,
  name: "reg_s[1]",
  name-pos: "end",bus: true,
  color : orange
  )
  wire.wire("w_i2c_module_reg_s2",
  ("i2c_module-port-reg_select","RSACK-port-E"),
  style: "zigzag", directed: true,
  name: "reg_s[2]",
  zigzag-ratio: 60%,
  name-pos: "end",bus: true,
  color : orange
  )
  wire.wire("w_i2c_module_reg_s3",
  ("i2c_module-port-reg_select","RBYTEA-port-E"),
  style: "zigzag", directed: true,
  name: "reg_s[3]",
  zigzag-ratio: 60%,
  name-pos: "end",bus: true,
  color : orange
  )
  wire.wire("w_i2c_module_reg_s4",
  ("i2c_module-port-reg_select","BUFFRECEIVE-port-E"),
  style: "zigzag", directed: true,
  name: "reg_s[4]",
  zigzag-ratio: 45%,
  name-pos: "end",bus: true,
  color : orange
  )
//Read Address Decoder
  element.block(
    x:(rel:0,to:"RIUSE.west"),
    y:(rel:-4,from:"BUFFRECEIVE.south",to:"addr_in"),
    w:7,h:5,id:"rd_addr_dec",
    name:"Read\nAddress\nDecoder",
    ports: (
      west: (
        (id:"addr_in",name:[addr#sub("[6:0]")]),
        (id:"rd",name:"rd"),
        (id:"cs",name:"cs")
        ),
      east: ((id:"select",name:[s#sub("[5:0]")]),)
    ),
    fill: util.colors.yellow
  )
  wire.stub(
    "rd_addr_dec-port-addr_in",
    "west", name:[addr#sub("[31:0]")])
  wire.stub(
    "rd_addr_dec-port-rd",
    "west", name:"rd")
  wire.stub("rd_addr_dec-port-cs",
  "west",name:"cs")

  element.multiplexer(
    x :(rel:12,to:"rd_addr_dec.east"),
    y :(from:"RNEEDA-port-Q",to:"in2"), id:"d_out_mux",
    w:1.5, h:7,
    entries: ("0","1","2","4","8","C"),
    fill: util.colors.purple
  )
  wire.stub("d_out_mux.east",
  "east",length: 1.5,
  name: [d_out#sub("[31:0]")])
  wire.stub("d_out_mux.south",
  "south",length: 1)
  wire.stub("d_out_mux-port-in0",
  "west",name:"32'b0")
  wire.wire("w_rd_addr_dec_mux",
  ("rd_addr_dec-port-select",
  (rel:(0,-1),to:"d_out_mux.south")),
  style: "zigzag",directed: true
  )
  wire.wire("w_RIUSE_d_out",
  ("RIUSE-port-Q",
  "d_out_mux-port-in1"),
  style: "zigzag",directed: true,
  name: "{31'b0,RIUSE}", name-pos: "end"
  )
  wire.wire("w_RNEEDA_d_out",
  ("RNEEDA-port-Q",
  "d_out_mux-port-in2"),
  style: "zigzag",directed: true,
  name: "{31'b0,RNEEDA}", name-pos: "end"
  )
  wire.wire("w_RSACK_d_out",
  ("RSACK-port-Q",
  "d_out_mux-port-in3"),
  style: "zigzag",directed: true,
  zigzag-ratio: 40%,
  name: "{31'b0,RSACK}", name-pos: "end"
  )
  wire.wire("w_RBYTE_d_out",
  ("RBYTEA-port-Q",
  "d_out_mux-port-in4"),
  style: "zigzag",directed: true,
  name: "{31'b0,RBYTEA}", name-pos: "end"
  )
  wire.wire("w_BUFFRECEIVE_d_out",
  ("BUFFRECEIVE-port-Q",
  "d_out_mux-port-in5"),
  style: "zigzag",directed: true,
  zigzag-ratio: 45%,
  name: "{24'b0,BUFFRECEIVE}", name-pos: "end"
  )

//I/O Buffers
 element.group(
   id:"io_buffs",
   stroke: 0pt,
   {
    gates.gate-buf(
      id:"SDA_tristate",
      x:(rel:0,to:"i2c_module.west"),
      y:(from:"i2c_module.south",to:"out",rel:-5),
      w:2,h:2,fill:util.colors.purple
    )
    wire.stub("SDA_tristate-port-in0",
    "west",name:"1'b0")
    wire.wire("w_to_SDA",
    (
      "SDA_tristate.north",
      "i2c_module-port-SDA_set"
      // "SDA_tristate-port-in0"
    ),
    style: "zigzag",
    zigzag-ratio: 80%,
    name: "w_to_SDA",name-pos: "end",
    zigzag-dir: "horizontal",
    reverse: true
    )
    element.block(
      id:"SDA_pad",
      x:(rel:1,to:"SDA_tristate.east"),
      y: (from:"SDA_tristate.east",
      to:"line"),
      w:1.5,h:1.5,name:"SDA\nPad",
      ports: (
        west:((id:"line"),)
      )
    )
    gates.gate-buf(
      id:"SDA_input",
      x:(rel:2,to:"SDA_pad"),
      y:(from:"i2c_module.south",to:"out",rel:-5),
      w:2,h:2,fill:util.colors.purple
    )
    wire.stub("SDA_input-port-out",
    "east",length: 0.5)
    wire.wire("w_SDA_pad",
    ("SDA_tristate-port-out","SDA_pad.west"))
    wire.wire("w_pad_SDA",
    ("SDA_pad.east","SDA_input-port-in0"))
    wire.wire("w_from_SDA",
    (
      (rel:(0.5,0),to:"SDA_input-port-out"),
      "i2c_module-port-SDA_rd"
      
    ),
    style: "zigzag",name:"w_from_SDA",
    name-pos: "end",zigzag-ratio: 40%,
    zigzag-dir: "horizontal"
    )

    gates.gate-buf(
      id:"SCL_tristate",
      x:(rel:2,to:"SDA_input.east"),
      y:(from:"i2c_module.south",to:"out",rel:-7),
      w:2,h:2,fill:util.colors.purple
    )
    wire.stub("SCL_tristate-port-in0",
    "west",name:"1'b0")
    wire.wire("w_to_SCL",
    (
      "SCL_tristate.north",
      "i2c_module-port-SCL_set"
      // "SDA_tristate-port-in0"
    ),
    style: "zigzag",
    zigzag-ratio: 80%,
    name: "w_to_SCL",name-pos: "end",
    zigzag-dir: "horizontal",
    reverse: true
    )
    element.block(
      id:"SCL_pad",
      x:(rel:1,to:"SCL_tristate.east"),
      y: (from:"SCL_tristate.east",
      to:"line"),
      w:1.5,h:1.5,name:"SCL\nPad",
      ports: (
        west:((id:"line"),)
      )
    )
    wire.wire("w_SCL_pad",
    (
      "SCL_tristate-port-out",
      "SCL_pad.west"
    ))
   }
   )
})
  })

= $I^2C$ Module
#circuiteria.circuit({
  import circuiteria : *
  element.group(name: [$I^2C$ Peripheral],
  name-anchor: "south" {

  })
})
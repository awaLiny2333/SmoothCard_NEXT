@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @State degree: number = 20;
  @State gen_size: number = 1;
  @State animation_progress: number = 0;
  @State is_showing_back: boolean = false;
  @State screen_width: number = 500;
  @State screen_height: number = 500;
  @State max_gen_size: number = 2;

  onPageShow(): void {
    setInterval(() => {
      if (this.is_showing_back) {
        this.animation_progress += Math.min((1 - this.animation_progress) / 10, 0.018)
      } else {
        this.animation_progress += Math.max((0 - this.animation_progress) / 12, -0.018)
      }
      this.degree = this.animation_progress * 540
      this.gen_size = 1 + this.animation_progress * (this.max_gen_size - 1)
    }, 10)
  }

  build() {
    RelativeContainer() {
      LinysRCard({ degree: this.degree, general_size: this.gen_size })
        .alignRules({
          middle: { anchor: "__container__", align: HorizontalAlign.Center },
          center: { anchor: "__container__", align: VerticalAlign.Center }
        })
        .onClick(() => {
          this.is_showing_back = !this.is_showing_back
        })
    }
    .backgroundColor("#E1E9E3")
    .padding(20)
    .height('100%')
    .width('100%')
    .onAreaChange((_o, n) => {
      this.screen_width = n.width as number
      this.screen_height = n.height as number
      this.set_max_gen_size(this.screen_width,this.screen_height)
    })
  }

  set_max_gen_size(w: number, h: number) {
    this.max_gen_size = Math.min(w, h) / 220
    if (this.max_gen_size > 2.5) {
      this.max_gen_size = 2.5
    }
  }

}

@Component
struct LinysRCard {
  @Prop general_size: number = 1;
  @State card_width: number = 171;
  @State card_height: number = 108;
  @Prop degree: number = 0;
  // 0 = Front, 180 = Back
  @State zoom_rate: number = 3;
  // Bigger than 1. Smaller the rate is, stronger the effect is.
  @State radius: number = 10;
  @State card_l: number = this.card_height;
  @State card_r: number = this.card_height;
  @State card_w: number = this.card_width;
  @Prop color_front: ResourceStr = "#436543"
  @Prop color_back: ResourceStr = "#153122"
  @State is_pressing: boolean = false;
  @State press_zoom: number = 1;

  aboutToAppear() {
    setInterval(() => {
      if (this.is_pressing) {
        this.press_zoom += (0.85 - this.press_zoom) / 5
      } else {
        this.press_zoom += (1 - this.press_zoom) / 5
      }
    }, 10)
  }

  build() {
    Polygon({
      width: this.get_com_width(),
      height: this.get_com_height(),
    })
      .points([
        [this.get_lx() * this.general_size * this.press_zoom, this.get_ly1() * this.general_size * this.press_zoom],
        [this.get_lx() * this.general_size * this.press_zoom, this.get_ly2() * this.general_size * this.press_zoom],
        [this.get_rx() * this.general_size * this.press_zoom, this.get_ry2() * this.general_size * this.press_zoom],
        [this.get_rx() * this.general_size * this.press_zoom, this.get_ry1() * this.general_size * this.press_zoom]
      ])
      .stroke(this.get_color())
      .strokeWidth(25 * this.general_size)
      .strokeLineJoin(LineJoinStyle.Round)
      .fill(this.get_color())
      .onTouch((event) => {
        if (event.type == TouchType.Up) {
          this.is_pressing = false
        } else {
          this.is_pressing = true
        }
      })
  }

  get_uni_deg() {
    return (this.degree % 360)
  }

  get_lrw() {
    this.degree = this.get_uni_deg()
    let uni_rad = (this.degree / 360) * 2 * Math.PI
    this.card_l = (1 - (Math.sin(uni_rad) / this.zoom_rate)) * this.card_height
    this.card_r = (1 + (Math.sin(uni_rad) / this.zoom_rate)) * this.card_height
  }

  get_lx() {
    this.get_lrw()

    if (this.degree > 180) {
      return this.card_width - ((this.degree - 180) / 180) * this.card_width
    } else {
      return (this.degree) / 180 * this.card_width
    }

  }

  get_rx() {
    let lx = this.get_lx()
    return 0.5 * this.card_width - (lx - 0.5 * this.card_width)
  }

  get_ly1() {
    this.get_lrw()

    return this.card_height * 0.5 - 0.5 * this.card_l
  }

  get_ly2() {
    this.get_lrw()

    return this.card_height * 0.5 + 0.5 * this.card_l
  }

  get_ry1() {
    this.get_lrw()
    return this.card_height * 0.5 - 0.5 * this.card_r
  }

  get_ry2() {
    this.get_lrw()
    return this.card_height * 0.5 + 0.5 * this.card_r
  }

  get_color() {
    if (this.get_uni_deg() > 90 && this.get_uni_deg() < 270) {
      return this.color_back
    } else {
      return this.color_front
    }
  }

  get_dist(x1: number, y1: number, x2: number, y2: number) {
    return Math.sqrt((x1 - x2) * (x1 - x2) + (y2 - y1) * (y2 - y1))
  }

  get_com_height() {
    return this.card_height * (1 + 1 / this.zoom_rate) * this.general_size * this.press_zoom
  }

  get_com_width() {
    return this.card_width * this.general_size * this.press_zoom
  }
}
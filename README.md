# Screenly-OSE setting up with resin.io

Setting up [Screenly OSE](https://www.screenly.io/ose/) with [resin.io](https://resin.io)

## Setup

* Follow the [getting started guide](https://docs.resin.io/raspberrypi3/python/getting-started/) regarding how to sign up to resin.io, create an application, and add a device.
* `git clone` this repository, then you can `git push` to your resin.io/Screenly application.
* Once the device downloads the application image, you'll see the splash screen and can navigate to the control dashboard
* In the resin.io dashboard, application or device, and `RESIN_HOST_CONFIG_gpu_mem` to a value at least `192` in the Fleet Configuration or Device Configurations menu (respectcively). If set in the Fleet Configuration, it will apply to all devices (present and future).
* If you would like to see more debug information in the dashboard, in the Environment Variables section set `DEBUG` to `1` (if don't want debug info later, just remove that environment variable)

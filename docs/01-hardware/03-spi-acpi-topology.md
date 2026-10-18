**Back:** [00-overview](./00-overview.md)

# SPI + ACPI topology

```
ACPI "FTE3600:00"
  +-- SPI device spi-FTE3600:00   (modalias acpi:FTE3600:FTE3600:)
        +-- SPI master spi0        (pxa2xx-spi @ PCI 00:12.6)
```

- PCI `00:12.6` is the Alder Lake PCH Serial IO SPI controller; it registers `spi0`.
- The FTE3600 ACPI node provides the SPI connection plus a reset GPIO and an edge
  interrupt. The clean-room glue module (`fte3600`) consumes exactly those ACPI
  resources and pairs a `spidev` node with an IRQ-only UIO node; it performs no
  SPI transfers itself.
- Route A instead expects a `focal_spi` module that exposes `/dev/focal_moh_spi`.

## Verify
Run `scripts/00-preflight.sh`; it prints the ACPI device, the SPI device and the
modalias, and flags the device as `unclaimed` when no driver is bound.

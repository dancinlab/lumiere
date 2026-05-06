#!/usr/bin/env swift
//
// scripts/measure_aperture_divergence.swift — F-MC-MVP-5 lens-flare physics
//
// Real F-gate closure: render 100 synthetic test scenes through the
// LensFlareFrameProcessor's 6-blade hexagonal aperture model and
// measure max blade-edge angle deviation from ideal hex geometry.
//
// Threshold: ≤ 5° max divergence per spec §19.2.
// Expected: does not fire (Born-Wolf 1999 §8 paraxial deviations
// ≤ 1°; geometric blade-edge model is exact).
//
// Pure offline — no device required. mk2 ships the geometric ideal
// check (always emits 0° divergence on the analytical model);
// integrating into the actual `CISunbeamsGenerator` rendering path
// for an empirical render is mk3.

import Foundation

func idealBladeAngles(blades: Int) -> [Double] {
    (0..<blades).map { Double($0) * (360.0 / Double(blades)) }
}

func maxDivergence(measured: [Double], ideal: [Double]) -> Double {
    zip(measured, ideal).map { abs($0 - $1) }.max() ?? 0.0
}

let blades = 6
let ideal = idealBladeAngles(blades: blades)
let measured = ideal // analytical: identical to ideal (geometric model is exact)
let div = maxDivergence(measured: measured, ideal: ideal)

print(#"{"status":"smoke-pass","gate":"F-MC-MVP-5","scope":"geometric-aperture-model","valid_for_F_gate_closure":false,"reason":"analytical model emits 0° divergence; empirical render through LensFlareFrameProcessor at 100-scene synthetic batch is mk3","blades":\#(blades),"max_divergence_deg":\#(div),"threshold_deg":5}"#)

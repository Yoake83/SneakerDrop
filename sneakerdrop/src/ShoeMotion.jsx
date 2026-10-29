import React, { useEffect, useRef, useState } from 'react';
import { ArrowUpRight, Pause, Play, RotateCcw, RotateCw } from 'lucide-react';
import './shoe-motion.css';

export default function ShoeMotion() {
  const stage = useRef(null);
  const frame = useRef(null);
  const [angle, setAngle] = useState(-8);
  const [paused, setPaused] = useState(false);
  const [reduced, setReduced] = useState(false);
  const [visible, setVisible] = useState(false);
  const [pageVisible, setPageVisible] = useState(true);

  useEffect(() => {
    const preference = matchMedia('(prefers-reduced-motion: reduce)');
    const updatePreference = () => setReduced(preference.matches);
    const updateVisibility = () => setPageVisible(!document.hidden);
    updatePreference();
    updateVisibility();
    preference.addEventListener('change', updatePreference);
    document.addEventListener('visibilitychange', updateVisibility);
    const observer = new IntersectionObserver(([entry]) => setVisible(entry.isIntersecting), { threshold: 0.05 });
    observer.observe(stage.current);
    return () => {
      observer.disconnect();
      preference.removeEventListener('change', updatePreference);
      document.removeEventListener('visibilitychange', updateVisibility);
      cancelAnimationFrame(frame.current);
    };
  }, []);

  function followPointer(event) {
    if (reduced || paused || event.pointerType === 'touch') return;
    const bounds = event.currentTarget.getBoundingClientRect();
    const x = (event.clientX - bounds.left) / bounds.width - 0.5;
    const y = (event.clientY - bounds.top) / bounds.height - 0.5;
    cancelAnimationFrame(frame.current);
    frame.current = requestAnimationFrame(() => {
      stage.current?.style.setProperty('--pointer-yaw', `${x * 22}deg`);
      stage.current?.style.setProperty('--pointer-pitch', `${y * -14}deg`);
    });
  }

  function resetPointer() {
    cancelAnimationFrame(frame.current);
    stage.current?.style.setProperty('--pointer-yaw', '0deg');
    stage.current?.style.setProperty('--pointer-pitch', '0deg');
  }

  const running = !paused && !reduced && visible && pageVisible;

  return (
    <section id="motion" className="motion-section" data-reveal aria-labelledby="motion-title">
      <div className="motion-copy">
        <span className="eyebrow">DESIGN IN MOTION / SD CONCEPT 01</span>
        <h2 id="motion-title">A DIFFERENT<br/>ANGLE.</h2>
        <p>Good design deserves a closer look. A fresh perspective on the everyday silhouette.</p>
        <a className="text-button" href="#collection">Find your rotation <ArrowUpRight size={18}/></a>
        <span className="motion-concept-note">AN ORIGINAL SNEAKERDROP DESIGN CONCEPT</span>
      </div>
      <div className="motion-showroom">
        <div
          ref={stage}
          id="shoe-stage"
          className={`shoe-stage ${running ? 'is-running' : ''}`}
          style={{ '--shoe-angle': `${angle}deg` }}
          onPointerMove={followPointer}
          onPointerLeave={resetPointer}
          aria-label="Sneaker concept in motion. Use the controls below to change its angle."
        >
          <span className="stage-coordinate">FIG. 001 / STONE & FOREST</span>
          <div className="shoe-orbit" aria-hidden="true"/>
          <span className="stage-lettering" aria-hidden="true">SD—01</span>
          <div className="shoe-shadow" aria-hidden="true"/>
          <div className="shoe-perspective">
            <div className="shoe-float">
              <img className="motion-sneaker" src="/images/motion-sneaker.png" alt="Original stone, slate and forest-green SneakerDrop concept sneaker" loading="lazy" draggable="false"/>
            </div>
          </div>
          <span className="stage-hint">A NEW WAY TO LOOK AT YOUR EVERYDAY.</span>
        </div>
        <div className="motion-controls">
          <div className="angle-controls" aria-label="Change shoe angle">
            <button className="icon-button" aria-label="Rotate sneaker left" aria-controls="shoe-stage" onClick={() => setAngle(value => Math.max(-30, value - 8))} disabled={angle <= -30}><RotateCcw size={17}/></button>
            <label className="angle-slider"><span className="sr-only">Sneaker tilt angle</span><input type="range" min="-30" max="30" step="1" value={angle} onChange={event => setAngle(Number(event.target.value))} aria-controls="shoe-stage" aria-valuetext={`${angle} degrees`}/></label>
            <button className="icon-button" aria-label="Rotate sneaker right" aria-controls="shoe-stage" onClick={() => setAngle(value => Math.min(30, value + 8))} disabled={angle >= 30}><RotateCw size={17}/></button>
          </div>
          {reduced ? <span className="motion-preference">Motion reduced</span> : <button className="motion-play" aria-pressed={paused} aria-controls="shoe-stage" onClick={() => { resetPointer(); setPaused(value => !value); }}>{paused ? <Play size={13}/> : <Pause size={13}/>}<span>{paused ? 'Play motion' : 'Pause motion'}</span></button>}
        </div>
      </div>
    </section>
  );
}

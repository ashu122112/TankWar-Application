package com.example.tankwar.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.tankwar.model.Terrain;

@Repository
public interface TerrainRepository extends JpaRepository<Terrain,Integer> {

}

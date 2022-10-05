// -*- scala -*-
import mill._, scalalib._
import coursier.MavenRepository

object hello extends ScalaModule {
  override def scalaVersion = "2.13.8"

  override def ivyDeps = super.ivyDeps() ++ Agg(ivy"dev.zio::zio:2.0.2")
}
